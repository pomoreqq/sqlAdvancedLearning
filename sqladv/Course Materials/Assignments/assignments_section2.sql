-- Connect to database

use maven_advanced_sql;
-- ASSIGNMENT 1: Basic Joins
-- Looking at the orders and products tables, which products exist in one table, but not the other?

-- View the orders and products tables
select * from orders;
select * from products;
-- Join the tables using various join types & note the number of rows in the output
select count(*) from products p
inner join orders o
on p.product_id = o.product_id;

select count(*) from products p
left join orders o
on p.product_id = o.product_id;
        
-- View the products that exist in one table, but not the other
SELECT	*
FROM	orders o LEFT JOIN products p
		ON o.product_id = p.product_id
WHERE	p.product_id IS NULL;
        
SELECT	*
FROM	orders o RIGHT JOIN products p
		ON o.product_id = p.product_id
WHERE	o.product_id IS NULL;

-- Pick a final JOIN type to join products and orders
select p.product_id,p.product_name,o.product_id from products p
left join orders o
on p.product_id = o.product_id
where o.product_id is NULL;

-- ASSIGNMENT 2: Self Joins
-- Which products are within 25 cents of each other in terms of unit price?

-- View the products table
select * from products;

-- Join the products table with itself so each candy is paired with a different candy
select p1.product_name,p1.unit_price,p2.product_name,p2.unit_price from products p1
inner join products p2
on p1.product_id <> p2.product_id;
        
-- Calculate the price difference, do a self join, and then return only price differences under 25 cents
select p1.product_name,p1.unit_price,p2.product_name,p2.unit_price, abs(p1.unit_price - p2.unit_price) as priceDiff from products p1
inner join products p2
on p1.product_id < p2.product_id
having abs(p1.unit_price - p2.unit_price) <= 0.25
order by priceDiff DESC;

