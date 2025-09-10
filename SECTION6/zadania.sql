use sakila;


-- 🔹 T1: „Wydatki klientów miesiąc po miesiącu”

-- Dla każdego klienta i miesiąca, pokaż:

-- first_name, last_name

-- miesiąc (MONTH(rental_date))

-- suma wydatków

-- różnica względem poprzedniego miesiąca

-- tylko jeśli klient miał więcej niż jedno wypożyczenie w historii

select c.first_name,c.last_name,month(p.payment_date) as month,sum(p.amount) as sumPerMonth from customer c
inner join payment p
on p.customer_id = c.customer_id
group by c.first_name,c.last_name,month;


select customer_id,count(rental_id) as rentalCount from rental
group by customer_id
having rentalCount> 1;


with isMoreOneRental as (
						select customer_id,count(rental_id) as rentalCount from rental
						group by customer_id
						having rentalCount> 1),
 sumPerMonthClient as (
						select c.first_name,c.last_name,month(p.payment_date) as month,sum(p.amount) as sumPerMonth from customer c
						inner join payment p
						on p.customer_id = c.customer_id
						where c.customer_id in (select customer_id from isMoreOneRental)
						group by c.first_name,c.last_name,month
						order by c.first_name,c.last_name,month)
select first_name,last_name,month,sumPerMonth,
lag(sumPerMonth) over(partition by first_name,last_name order by month) as priorMonth,
sumPerMonth - lag(sumPerMonth) over(partition by first_name,last_name order by month) as monthDiff
 from sumPerMonthClient;
 
 
 
--  🔹 T2: „Najlepiej zarabiające wypożyczenia”

-- Dla każdego sklepu (store_id) znajdź:

-- TOP 3 wypożyczenia (rental_id) o najwyższej sumie płatności,

-- wraz z kwotą, datą, first_name, last_name klienta.

-- Jeśli jest remis, pokaż wszystkie rekordy w TOP 3.
-- with bigTable as (
-- select st.staff_id,r.rental_id,sum(p.amount) as total from store s
-- inner join staff st
-- on s.store_id = st.store_id
-- inner join rental r
-- on r.staff_id = st.staff_id
-- inner join payment p
-- on p.rental_id = r.rental_id
-- inner join customer c
-- on p.customer_id = c.customer_id
-- group by st.staff_id,r.rental_id
-- order by total desc
-- )
-- select s.store_id,rental_id from bigTable;


-- 📋 Zadania – Window Functions (Sakila DB)
-- 1. ROW_NUMBER, RANK, DENSE_RANK

-- Znajdź pierwszy film (według ceny wypożyczenia) w każdej kategorii.
-- select count(distinct(name)) from category;


with joinedTable as (select f.title,c.name,f.rental_rate from film f
inner join film_category fa
on f.film_id = fa.film_id
inner join category c
on fa.category_id = c.category_id),
  tableWithRank as (
 select title,name,rental_rate,
rank() over(partition by name order by rental_rate DESC,title,name) as r
 from joinedTable
 )
select * from tableWithRank
where r = 1;

-- Nadaj numerację filmom w każdej kategorii według długości filmu (length).
with joinedTable as (select c.category_id,f.title,c.name,f.length from film f
inner join film_category fa
on f.film_id = fa.film_id
inner join category c
on fa.category_id = c.category_id),
 rankedTable as (
	select category_id,title,name,length,
    row_number() over(partition by category_id order by length DESC) as r
    from joinedTable
 )
 select * from rankedTable
 where r = 1;
-- Znajdź 3 najczęściej wypożyczane filmy w każdej kategorii.
with bigTable as ( 
select c.category_id,c.name,f.title,count(rental_id) as rentalCount from film f
inner join film_category fa
on f.film_id = fa.film_id
inner join category c
on fa.category_id = c.category_id
inner join inventory i
on i.film_id = f.film_id
inner join rental r
on r.inventory_id = i.inventory_id
group by c.category_id,f.title
),
 tableWithRowNumber as (
 select category_id,name,title,rentalCount,
row_number() over(partition by category_id order by rentalCount DESC) as rnk
 from bigTable
 )
select * from tableWithRowNumber
where rnk <= 3;


-- 2. FIRST_VALUE, LAST_VALUE, NTH_VALUE

-- Dla każdego klienta pokaż pierwszą i ostatnią datę wypożyczenia.
with joinedTable as (
select c.customer_id,c.first_name,c.last_name,r.rental_date from customer c
inner join rental r
on c.customer_id = r.customer_id
),
 firstAndLast as (
 select customer_id,first_name,last_name,rental_date,
first_value(rental_date) over(partition by customer_id order by rental_date) as firstRental,
last_value(rental_date) over(partition by customer_id) as lastRental,
row_number() over(partition by customer_id) as rowNumber
from joinedTable
 )
 select * from firstAndLast
 where rowNumber = 1;
-- Znajdź pierwszy film (alfabetycznie) wypożyczony przez każdego klienta.
with cte as (
select c.customer_id,c.first_name,c.last_name,f.title,r.rental_date from customer c
inner join rental r
on r.customer_id = c.customer_id
inner join inventory i
on r.inventory_id = i.inventory_id
inner join film f
on f.film_id = i.film_id
),
firstAndLast as (
select customer_id,first_name,last_name,title,
first_value(title) over(partition by customer_id order by rental_date) as firstTitle,
row_number() over(partition by customer_id) as rowNumber
 from cte
)
select * from firstAndLast
where rowNumber = 1;
-- Pokaż dla każdej kategorii filmów 3. najdroższy film (wg rental_rate).
with cte as (
select c.category_id, c.name,f.title,f.rental_rate from film f
inner join film_category fa
on fa.film_id = f.film_id
inner join category c
on c.category_id = fa.category_id
),
cte2 as (
select category_id,name,title,rental_rate,
row_number() over(partition by category_id order by rental_rate DESC) as rnk
from cte
)
select * from cte2 
where rnk = 3;
-- 3. LEAD & LAG

-- Policz różnicę w liczbie wypożyczeń między kolejnymi miesiącami w całej bazie.
with cte as (
select year(rental_date) as yr,month(rental_date) as mnth,count(rental_id) as rentalCount from rental
group by yr,mnth
order by mnth
),
cteWithPriorMonth as (
select yr,mnth,rentalCount,
lag(rentalCount) over(order by yr,mnth) as priorMonthCount
from cte
)
select yr,mnth,rentalCount,priorMonthCount, rentalCount - priorMonthCount as countDiff
from cteWithPriorMonth;
-- Dla każdego klienta pokaż różnicę w liczbie dni między kolejnymi wypożyczeniami.
with cte as (
select c.customer_id,c.first_name,c.last_name,r.rental_id,r.rental_date from customer c
inner join rental r
on c.customer_id = r.customer_id
),
 cte2 as (
 select customer_id,first_name,last_name,rental_id,rental_date,
lag(rental_date) over(partition by customer_id order by rental_date) as priorDay
 from cte
 )
 select customer_id,first_name,last_name,rental_id,rental_date,priorDay, datediff(rental_date,priorDay) as diff
 from cte2;
-- Porównaj płatności klientów: pokaż wartość płatności oraz poprzednią płatność tego samego klienta.
with cte as (select c.customer_id,c.first_name,c.last_name,p.payment_id,p.amount from customer c
inner join payment p
on p.customer_id = c.customer_id),
 cte2 as (select customer_id,first_name,last_name,payment_id,amount,
lag(amount) over(partition by customer_id order by payment_id) as priorAmount
from cte)
select customer_id,first_name,last_name,payment_id,amount,priorAmount, amount-priorAmount as diff
from cte2;
-- 4. NTILE

-- Podziel klientów na 4 kwartyle według sumy wszystkich płatności.
with cte as (
select c.customer_id,c.first_name,c.last_name,sum(p.amount) as sumAmount from customer c
inner join payment p
on c.customer_id = p.customer_id
group by c.customer_id
)
select customer_id,first_name,last_name, sumAmount,
ntile(4) over(order by sumAmount DESC)
from cte;
-- Podziel filmy na 5 grup według długości (length).
select title,length,ntile(5) over(order by length DESC) from film;
-- Stwórz ranking aktorów według liczby filmów i podziel ich na tercyle.
with cte as (select a.actor_id,a.first_name,a.last_name,count(f.film_id) filmCount from actor a
inner join film_actor fa
on fa.actor_id = a.actor_id
inner join film f
on f.film_id = fa.film_id
group by a.actor_id)
select actor_id,first_name,last_name,filmCount,ntile(3) over(order by filmCount DESC) as tercile
from cte;
-- 5. Mixed / Case Study

-- Znajdź w każdej kategorii filmy, które należą do top 10% najdłuższych filmów.
with cte as (
select f.film_id,f.title,c.category_id,c.name,f.length from film f
inner join film_category fc
on fc.film_id = f.film_id
inner join category c 
on c.category_id = fc.category_id
),
cte2 as (
select category_id,title,name,length, ntile(10) over(partition by category_id order by length DESC) as tenGroups
from cte
)
select * from cte2 where tenGroups = 1;
-- Pokaż ranking klientów według całkowitej kwoty płatności i wskaż, którzy znajdują się w top 20%.
with cte as (
select c.customer_id,c.first_name,c.last_name,sum(p.amount) as sumAmount from customer c
inner join payment p
on p.customer_id = c.customer_id
group by c.customer_id
),
cte2 as (
select customer_id,first_name,last_name, sumAmount,
rank() over(order by sumAmount DESC) as rnk,
ntile(20) over(order by sumAmount DESC) as pentyl
from cte
)
select * from cte2
where pentyl = 1;
-- Dla każdego sklepu policz miesięczne przychody i pokaż zmianę procentową w stosunku do poprzedniego miesiąca.
with cte as (
select s.store_id,sum(p.amount) sumAmount,year(p.payment_date) as yr,month(p.payment_date) as mnth from store s
inner join staff sta
on s.store_id = sta.store_id
inner join payment p
on sta.staff_id = p.staff_id
group by s.store_id,yr,mnth
order by s.store_id,yr,mnth
),
 cte2 as (
 select store_id, sumAmount,yr,mnth,lag(sumAmount) over(partition by store_id) as priorMonthSumAmount from cte
 )
select store_id,yr,mnth,sumAmount, priorMonthSumAmount, (sumAmount/priorMonthSumAmount)*100 as percentageDiff from cte2;
-- Podziel filmy na kwartyle wg popularności (liczba wypożyczeń) i porównaj średni przychód w każdej grupie.
with cte as (
select f.film_id,count(r.rental_id) * f.rental_rate as income from film f
inner join inventory i
on i.film_id = f.film_id
inner join rental r
on r.inventory_id = i.inventory_id
group by film_id
),
 cte2 as (
 select film_id,income,ntile(4) over(order by income desc) as quartile from cte
 )
 select quartile,avg(income) from cte2
 group by quartile;
-- Stwórz zestawienie: dla każdego klienta wskaż jego największą płatność, najmniejszą płatność i różnicę między nimi.
with cte as (
select c.customer_id,c.first_name,c.last_name,p.amount from customer c
inner join payment p
on c.customer_id = p.customer_id
),
cte2 as (
select customer_id,first_name,last_name,amount,
first_value(amount) over(partition by customer_id order by amount) as lowestAmount,
last_value(amount) over(partition by customer_id) as highestAmount
from cte
),
cte3 as (
select customer_id,first_name,last_name,amount,lowestAmount,highestAmount, highestAmount-lowestAmount as amountAmplitude,
row_number() over(partition by customer_id) rowNumber
 from cte2
)
select customer_id,first_name,last_name,amountAmplitude,rowNumber from cte3
where rowNumber =1;