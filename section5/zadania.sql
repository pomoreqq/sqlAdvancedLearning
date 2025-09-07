use sakila;
-- A. Subqueries in SELECT

-- T1. Dla każdego klienta wyświetl first_name, last_name oraz łączną sumę jego płatności jako kolumnę total_paid (podzapytanie w SELECT).

select first_name,last_name,(select sum(amount) 
from payment where  customer.customer_id = payment.customer_id) as totalPaid
from customer;

-- T2. Dla każdego aktora wypisz first_name, last_name i liczbę filmów, w których wystąpił (film_count) – użyj podzapytania w SELECT.
select first_name,last_name, (select count(*) from film_actor
where film_actor.actor_id = actor.actor_id)
from actor;


-- B. Subqueries in FROM

-- T3. Oblicz średnią długość filmu (length) dla każdego ratingu (G, PG, itp.) – użyj podzapytania w FROM.
select t.rating,t.avgLen from (
select rating,avg(length) as avgLen from film
group by rating) as t;
-- T4. Dla każdej kategorii pokaż średnią długość filmu – użyj podzapytania w FROM, które łączy film i film_category.

select t.name,t.avgLen from
( select c.name,avg(f.length) as avgLen from film f
inner join film_category fa
on fa.film_id = f.film_id 
inner join category c
on fa.category_id = c.category_id
group by c.name) as t;



-- C. Subqueries in WHERE / HAVING

-- T5. Wyświetl tytuły filmów, które zostały wypożyczone co najmniej raz (podzapytanie w WHERE).
select title from film
where film_id in (select film_id from inventory);
-- T6. Pokaż klientów, którzy nigdy nie wypożyczyli filmu.
select first_name,last_name from customer
where customer_id not in ( select customer_id from rental);
-- T7. Pokaż tylko tych klientów, których łączna suma płatności przekracza średnią ze wszystkich klientów (użyj HAVING + podzapytanie).
select c.first_name,c.last_name, sum(p.amount) from customer c
inner join payment p
on c.customer_id = p.customer_id
group by c.customer_id
having sum(p.amount) > (select avg(t.totalSum) from 
(select sum(amount) as totalSum from payment group by customer_id) as t);
-- T8. Pokaż filmy, których replacement cost przekracza maksymalną wartość wśród filmów ratingu 'G'.
select title from film
where replacement_cost > (select max(replacement_cost) from film
group by rating
having rating = 'G');

-- T9. Pokaż aktorów, którzy zagrali w większej liczbie filmów niż średnia liczba filmów na aktora.
select a.first_name,a.last_name, count(fa.film_id) from actor a
inner join film_actor fa
on fa.actor_id = a.actor_id
group by a.actor_id
having count(fa.film_id) > (select  avg(t.totalFilms) from
(select count(film_id) as totalFilms from film_actor group by actor_id) as t);

-- D. IN, NOT IN, EXISTS, NOT EXISTS

-- T10. Pokaż filmy, które NIE mają przypisanej kategorii (NOT IN + film_category).
select title from film
where film_id not in(select film_id from film_category);
-- T11. Pokaż klientów, którzy dokonali przynajmniej jednej płatności (użyj EXISTS).
select first_name,last_name from customer
where  exists(select customer_id from payment
where customer.customer_id = payment.customer_id);
-- T12. Pokaż klientów, którzy nie dokonali żadnej płatności (NOT EXISTS).
select first_name,last_name from customer
where not exists(select customer_id from payment
where customer.customer_id = payment.customer_id);



-- E. CTE – Common Table Expressions

-- T13. Stwórz CTE z łączną kwotą płatności dla każdego klienta. Następnie z głównego zapytania wybierz tylko tych, którzy zapłacili powyżej 100.
with t as (
select c.first_name,c.last_name, sum(p.amount) as sumAmount from customer c
inner join payment p
on p.customer_id = c.customer_id
group by c.customer_id)
select * from t 
where t.sumAmount > 100;

-- T14. Użyj CTE do obliczenia liczby filmów przypisanych do każdej kategorii. Pokaż tylko te kategorie, które mają więcej niż 50 filmów.
with t as (
select c.name,count(fc.film_id) as filmCount from category c
inner join film_category fc
on fc.category_id = c.category_id
group by c.name)
select * from t
where t.filmCount > 50;
-- T15. Zbuduj CTE, który oblicza średni rental duration per rating, a potem wybierz tylko te ratingi, gdzie ta wartość przekracza 4 dni.
with t as (
select rating,avg(rental_duration) as total from
film
group by rating)
select * from t
where t.total > 4;
-- F. CTE z JOINAMI i filtrowaniem

-- T16. Zbuduj CTE łączący customer, rental i payment, aby obliczyć ile klient zapłacił za każde wypożyczenie – pokaż first_name, last_name, amount, rental_id.
with t as ( select
c.first_name,c.last_name,p.amount,r.rental_id from customer c
inner join payment p on p.customer_id = c.customer_id
inner join rental r on r.customer_id = c.customer_id)
select * from t;



-- T17. Użyj CTE do wyciągnięcia top 10 aktorów pod względem liczby filmów.
with t as (select a.first_name,a.last_name, count(fa.film_id) as filmCount
from actor a 
inner join film_actor fa
on fa.actor_id = a.actor_id
group by a.actor_id)
select * from t
order by filmCount DESC
limit 10;
-- G. Multiple CTEs

-- T18. Pierwszy CTE: klienci z ich łączną sumą płatności.
-- Drugi CTE: średnia suma płatności ze wszystkich klientów.
-- Z głównego zapytania wyciągnij klientów, którzy zapłacili więcej niż ta średnia.
with firstT as (select c.first_name as name, c.last_name as surname,sum(p.amount) as totalPerClient
from customer c
inner join payment p
on c.customer_id = p.customer_id
group by c.customer_id),
	secondT as (select avg(t.total) as totalAvg from (select sum(amount) as total from payment group by customer_id) as t) 
select firstT.name, firstT.surname,totalPerClient from firstT
where firstT.totalPerClient > (Select totalAvg from secondT);
-- H. Recursive CTE

-- T19. Zbuduj rekursywny CTE, który wygeneruje liczby od 1 do 50.
with recursive rec(digits) as (
select 1
union all
select digits+1
from rec
where digits <= 50
)
select digits from rec;
-- T20. Zbuduj rekursywny CTE do wyliczenia łańcucha podwojeń:

with recursive chain(dig) as (
select 1
union all
select dig*2
from chain
where dig <= 1000)
select dig from chain;