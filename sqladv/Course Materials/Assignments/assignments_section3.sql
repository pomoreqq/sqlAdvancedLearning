-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Subqueries in the SELECT clause

-- View the products table
select * from products;

-- View the average unit price
select avg(unit_price) from products;

-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price
select product_id,product_name,unit_price, ( select avg(unit_price) from products) as avgunitprice, unit_price - ( select avg(unit_price) from products) as diffFromAvg
from products;
 
-- Order the results from most to least expensive
select product_id,product_name,unit_price, ( select avg(unit_price) from products) as avgunitprice, unit_price - ( select avg(unit_price) from products) as diffFromAvg
from products
order by unit_price DESC;

-- ASSIGNMENT 2: Subqueries in the FROM clause

-- Return the factories, product names from the factory
-- and number of products produced by each factory


-- All factories and products
	select * from products;

-- All factories and their total number of products
select factory, count(product_id) as numProducts from products
group by factory;

-- Final query with subqueries
select p.factory, p.product_name, p2.numProducts from
products p inner join ( select factory, count(product_id) as numProducts from products
group by factory) as p2
on p.factory = p2.factory
order by p.factory;

-- ASSIGNMENT 3: Subqueries in the WHERE clause

-- View all products from Wicked Choccy's
select * from products
where factory = 'Wicked Choccys''s';

-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's


-- ASSIGNMENT 4: CTEs

-- View the orders and products tables


-- Calculate the amount spent on each product, within each order


-- Return all orders over $200


-- Return the number of orders over $200


-- ASSIGNMENT 5: Multiple CTEs

-- Copy over Assignment 2 (Subqueries in the FROM clause) solution


-- Rewrite the Assignment 2 subquery solution using CTEs instead


