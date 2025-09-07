-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Subqueries in the SELECT clause

-- View the products table
select * from products;

-- View the average unit price
select avg(unit_price) from products;

-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price
select product_id,product_name,unit_price,(select avg(unit_price) from products) as avgUnitPrice, unit_price - (select avg(unit_price) from products) as unitPriceDiff
from products;
 
-- Order the results from most to least expensive
select product_id,product_name,unit_price,(select avg(unit_price) from products) as avgUnitPrice, unit_price - (select avg(unit_price) from products) as unitPriceDiff
from products
order by unitPriceDiff Desc;

-- ASSIGNMENT 2: Subqueries in the FROM clause

-- Return the factories, product names from the factory
-- and number of products produced by each factory
select * from products;

select factory,count(*) as numProducts from products
group by factory,product_name;

-- All factories and their total number of products
select factory,count(*) as numProducts from products
group by factory;


-- Final query with subqueries
select p2.factory,p1.product_name,p2.numProducts from products p1
inner join ( select factory,count(*) as numProducts from products
group by factory) as p2
on p1.factory = p2.factory
order by p2.factory;
-- multiple subqueries
select p1.factory,p1.product_name,p2.numProducts from
( select factory,product_name from products ) p1
left join 
( select factory,count(*) as numProducts from products
group by factory) p2
on p1.factory = p2.factory
order by p1.factory;
-- ASSIGNMENT 3: Subqueries in the WHERE clause

-- View all products from Wicked Choccy's
select * from products 
where factory = "Wicked Choccy's";

-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's
select * from products
where unit_price < all(select unit_price from products 
where factory = "Wicked Choccy's");

-- ASSIGNMENT 4: CTEs

-- View the orders and products tables
select * from orders;
select * from products;
-- Calculate the amount spent on each product, within each order
select o.order_id, sum(o.units * p.unit_price) as totalAmountSpent
from orders o
inner join products p
on p.product_id = o.product_id
group by o.order_id;



-- Return all orders over $200
with result as ( 
select o.order_id, sum(o.units * p.unit_price) as totalAmountSpent
from orders o
inner join products p
on p.product_id = o.product_id
group by o.order_id )
select * from result
where result.totalAmountSpent > 200;

-- Return the number of orders over $200
with result as ( 
select o.order_id, sum(o.units * p.unit_price) as totalAmountSpent
from orders o
inner join products p
on p.product_id = o.product_id
group by o.order_id )
select count(*) from result
where result.totalAmountSpent > 200;

-- ASSIGNMENT 5: Multiple CTEs

-- Copy over Assignment 2 (Subqueries in the FROM clause) solution
select p1.factory,p1.product_name,p2.numProducts from
( select factory,product_name from products ) p1
left join 
( select factory,count(*) as numProducts from products
group by factory) p2
on p1.factory = p2.factory
order by p1.factory;

-- Rewrite the Assignment 2 subquery solution using CTEs instead
with p1 as (
			select factory,product_name from products ),
	p2 as ( select factory,count(*) as numProducts from products
			group by factory)
select * from p1
left join p2
on p1.factory = p2.factory
order by p1.factory;

