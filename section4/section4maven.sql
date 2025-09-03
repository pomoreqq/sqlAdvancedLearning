-- 🧩 T1: "Najbardziej aktywni aktorzy"

-- Pokaż 10 aktorów, którzy zagrali w największej liczbie filmów.
-- Zwróć: first_name, last_name, film_count (alias), sortuj malejąco.

use sakila;

select a.first_name,a.last_name,count(*) as film_count from actor a
inner join film_actor fa
on a.actor_id = fa.actor_id
inner join film f
on f.film_id = fa.film_id
group by a.actor_id
order by count(*) DESC
limit 10;


-- 🧩 T2: "Filmy bez kategorii"

-- Wyświetl listę tytułów filmów, które nie mają przypisanej żadnej kategorii.
-- (Czyli brak w film_category!)


select f.title,fc.category_id from film f
left join film_category fc
on f.film_id = fc.film_id
where fc.category_id is NULL;

-- 🧩 T3: "Użytkownicy-widmo"

-- Pokaż klientów, którzy nigdy nic nie wypożyczyli ani nie dokonali żadnej płatności.
-- Zwróć: first_name, last_name, email


SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON c.customer_id = p.customer_id
WHERE r.rental_id IS NULL AND p.payment_id IS NULL;

-- 🧩 T4: "Self JOIN – współlokatorzy"

-- Wypisz pary klientów, którzy mieszkają na tym samym adresie (address_id).
-- Zwróć client_1, client_2, address_id
-- Unikaj duplikatów (np. Jan–Anna i Anna–Jan to to samo).
 
 select c1.first_name as client_1,c1.address_id,c2.first_name as client_2 from customer c1
 inner join customer c2
 on c1.address_id = c2.address_id
 where c1.first_name>c2.first_name;

-- 🧩 T5: "Cross JOIN – lista losowań"

-- Stwórz sztuczną listę: wszystkie możliwe pary language × category.
-- Zwróć language_name, category_name.
-- Posortuj alfabetycznie.

select l.name,c.name from language l
cross join category c;