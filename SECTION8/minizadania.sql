use sakila;
-- Znajdź aktorów z tym samym nazwiskiem.
select actor_id,first_name,last_name,
row_number() over(partition by last_name)
 from actor;
 
--  Sprawdź, ilu klientów ma wspólny adres.
select address_id, count(*) from customer
group by address_id
having count(*) > 1; -- 0 klientow ma wspolny adres
-- Pokaż filmy, które mają identyczny length i rental_rate.
select title,length,rental_rate, row_number() over(partition by length,rental_rate)
from film;


-- Min / Max Value Filtering

-- Dla każdej kategorii znajdź film o największej długości.
with cte as (
select f.title,c.name,f.length from film f
inner join film_category fc
on fc.film_id = f.film_id
inner join category c
on c.category_id = fc.category_id
),
cte2 as(
select name,title,length,row_number() over(partition by name order by length DESC) rwnmbr
from cte
)
select * from cte2
where rwnmbr = 1;
-- Znajdź klientów z najwyższą i najniższą pojedynczą płatnością.
with cte as (
select customer_id,min(amount) as maxAmount,max(amount) as minAmount from payment
group by customer_id)
select * from cte
inner join payment
on payment.customer_id = cte.customer_id AND payment.amount in(minAmount,maxAmount);
-- Pokaż TOP 3 filmy o największej liczbie wypożyczeń w całej bazie.
with joinedTable as (
select f.film_id,f.title,count(r.rental_id) as rentalCount
 from film f
inner join inventory i
on f.film_id = i.film_id 
inner join rental r
on r.inventory_id = i.inventory_id
group by film_id
order by rentalCount DESC
),
cte2 as (
select *,dense_rank() over(order by rentalCount DESC) as rnk from joinedTable
)
select * from cte2
where rnk <= 3;

:

-- 🔹 Z1: Najkrótszy i najdłuższy film w każdej kategorii
with cte as (select c.name,f.title,f.length from film f
inner join film_category fc
on f.film_id = fc.film_id
inner join category c
on c.category_id = fc.category_id
),
cte2 as (
select name,title,length, rank() over(partition by name order by length DESC) as rnk,
rank() over(partition by name order by length) as rnk2 from cte)
select * from cte2
where rnk=1 or rnk2=1;
 -- druga wersja
 
 WITH cte AS (
  SELECT 
    c.category_id,
    c.name,
    MIN(f.length) AS min_length,
    MAX(f.length) AS max_length
  FROM film f
  JOIN film_category fc ON f.film_id = fc.film_id
  JOIN category c ON c.category_id = fc.category_id
  GROUP BY c.category_id, c.name
)
SELECT 
  name,
  title,
  length
FROM cte
JOIN film_category fc ON fc.category_id = cte.category_id
JOIN film f ON f.film_id = fc.film_id
WHERE f.length IN (cte.min_length, cte.max_length);




-- 🔹 Z2: Najstarsze i najnowsze wypożyczenie w każdym sklepie
select s.store_id,min(r.rental_date) as oldsetDate,max(rental_date) as recentlyDate from rental r
inner join staff st
on st.staff_id = r.staff_id
inner join store s
on s.store_id = st.store_id
group by s.store_id;

-- 🔹 Z3: Najwięcej i najmniej płacący klient (łącznie)

-- Znajdź klienta z największą sumą płatności i klienta z najmniejszą sumą płatności (łącznie).
with cte as (
select c.customer_id, sum(p.amount) as sumAmount from customer c
inner join payment p 
on p.customer_id = c.customer_id
group by customer_id
),
 cte2 as (select customer_id,sumAmount from cte
where sumAmount = (select min(sumAmount)from cte) OR sumAmount = (select max(sumAmount)from cte))
select * from cte2
inner join customer
on customer.customer_id = cte2.customer_id;



-- 🔹 Pivoting
select distinct rating from film;
-- Pokaż liczbę filmów w każdej kategorii rozbitą na ratingi (np. G, PG, R…).
select c.name,
SUM(CASE WHEN f.rating = 'PG'    THEN 1 ELSE 0 END) AS PG,
    SUM(CASE WHEN f.rating = 'G'     THEN 1 ELSE 0 END) AS G,
    SUM(CASE WHEN f.rating = 'NC-17' THEN 1 ELSE 0 END) AS NC17,
    SUM(CASE WHEN f.rating = 'PG-13' THEN 1 ELSE 0 END) AS PG13,
    SUM(CASE WHEN f.rating = 'R'     THEN 1 ELSE 0 END) AS R,
    COUNT(*) AS filmCount from film f
inner join film_category fc
on fc.film_id = f.film_id
inner join category c
on c.category_id = fc.category_id
group by c.name;
-- Policz miesięczne przychody i zaprezentuj je jako kolumny miesięcy.
SELECT 
    YEAR(payment_date) AS yr,
    SUM(CASE WHEN MONTH(payment_date) = 1 THEN amount ELSE 0 END) AS Jan,
    SUM(CASE WHEN MONTH(payment_date) = 2 THEN amount ELSE 0 END) AS Feb,
    SUM(CASE WHEN MONTH(payment_date) = 3 THEN amount ELSE 0 END) AS Mar,
    SUM(CASE WHEN MONTH(payment_date) = 4 THEN amount ELSE 0 END) AS Apr,
    SUM(CASE WHEN MONTH(payment_date) = 5 THEN amount ELSE 0 END) AS May,
    SUM(CASE WHEN MONTH(payment_date) = 6 THEN amount ELSE 0 END) AS Jun,
    SUM(CASE WHEN MONTH(payment_date) = 7 THEN amount ELSE 0 END) AS Jul,
    SUM(CASE WHEN MONTH(payment_date) = 8 THEN amount ELSE 0 END) AS Aug,
    SUM(CASE WHEN MONTH(payment_date) = 9 THEN amount ELSE 0 END) AS Sep,
    SUM(CASE WHEN MONTH(payment_date) = 10 THEN amount ELSE 0 END) AS Oct,
    SUM(CASE WHEN MONTH(payment_date) = 11 THEN amount ELSE 0 END) AS Nov,
    SUM(CASE WHEN MONTH(payment_date) = 12 THEN amount ELSE 0 END) AS Dece,
    SUM(amount) AS total
FROM payment
GROUP BY YEAR(payment_date)
ORDER BY yr;

-- Pokaż liczbę klientów w podziale na sklepy i aktywność (aktywny/nieaktywny).
select s.store_id,
sum(case when c.active = 1 then 1 else 0 end) as activeCount,
sum(case when c.active = 0 then 1 else 0 end)as inActiveCount,
count(*) as clientCount from customer c
inner join store s
on s.store_id = c.store_id
group by s.store_id;
-- 🔹 Rolling Calculations

-- Policz narastającą sumę płatności dla całej bazy wg daty.
with cte as (
select year(payment_date) as yr,month(payment_date) as mnth, sum(amount) as totalSum
from payment
group by yr,mnth
order by yr,mnth
)
select yr,mnth,totalSum,
sum(totalSum) over(order by yr,mnth) from cte;
-- Dla każdego klienta pokaż różnicę w dniach między kolejnymi wypożyczeniami.
-- to zadanie z lag i to dlugie nie chce mi sie go robic juz robilem takie
-- Policz miesięczne przychody i różnicę względem poprzedniego miesiąca.
-- to tez zadanie z lag to samo nie chce mi sie juz robilismy je
