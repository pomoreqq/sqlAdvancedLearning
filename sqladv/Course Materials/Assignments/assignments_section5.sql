-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Numeric functions

-- Calculate the total spend for each customer
select c.customer_id,sum(o.units*p.unit_price) as sumPerCustomer from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join products p
on p.product_id = o.product_id
group by c.customer_id
order by sumPerCustomer DESC;

-- Put the spend into bins of $0-$10, $10-20, etc.
with cte as (
select c.customer_id,sum(o.units*p.unit_price) as sumPerCustomer from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join products p
on p.product_id = o.product_id
group by c.customer_id
order by sumPerCustomer DESC
)
select customer_id,sumPerCustomer,floor(sumPerCustomer/10) as sumBin
from cte;

-- Number of customers in each spend bin
with cte as (
select c.customer_id,sum(o.units*p.unit_price) as sumPerCustomer from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join products p
on p.product_id = o.product_id
group by c.customer_id
order by sumPerCustomer DESC
),
cte2 as (
select customer_id,sumPerCustomer,floor(sumPerCustomer/10) * 10 as sumBin
from cte
)
select sumBin,count(customer_id) from cte2
group by sumBin;

-- ASSIGNMENT 2: Datetime functions

-- Extract just the orders from Q2 2024
select order_id,order_date,date_add(order_date,INTERVAL 2 DAY ) as ship_date from orders
where year(order_date) = 2024 AND month(order_date) between 4 and 6;
-- Add a column called ship_date that adds 2 days to each order date
select order_id,order_date,date_add(order_date,INTERVAL 2 DAY ) as ship_date from orders
where year(order_date) = 2024 AND month(order_date) between 4 and 6;

-- ASSIGNMENT 3: String functions

-- View the current factory names and product IDs
select factory,product_id from products;

-- Remove apostrophes and replace spaces with hyphens
select replace(replace(factory,"'",''),' ','-') as factory,product_id from products;

-- Create new ID column called factory_product_id
with cte as (
select replace(replace(factory,"'",''),' ','-') as factory,product_id from products
)
select factory,product_id,concat(factory,'-',product_id) as factory_product_id from cte;
-- ASSIGNMENT 4: Pattern matching

-- View the product names
select product_name from products;

-- Only extract text after the hyphen for Wonka Bars
select product_name,replace(product_name,'Wonka Bar - ','') as new from products;

-- Alternative using substrings
select product_name,
case
	when product_name like 'Wonka Bar%' then substr(product_name, instr(product_name,'-') + 2)
    else product_name
    end as cleaned
 from products;


-- ASSIGNMENT 5: Null functions

-- View the columns of interest
select product_name,factory,division from products;
-- Replace NULL values with Other
select product_name,factory,division,ifnull(division,'Other') withOther from products;

-- Find the most common division for each factory
select factory,division,count(*) as productCount from products
where division is not NULL
group by factory,division
order by factory,division,productCount DESC;

-- Replace NULL values with top division for each factory
with cte as (select factory,division,count(*) as productCount from products
where division is not NULL
group by factory,division
order by factory,division,productCount DESC),
cte2 as (
select factory,division,productCount,
rank() over(partition by factory order by productCount DESC) as rnk
from cte
)
select factory,divsion from cte2 where rnk = 1;
-- Replace division with Other value and top division
with cte as (select factory,division,count(*) as productCount from products
where division is not NULL
group by factory,division
order by factory,division,productCount DESC),
cte2 as (
select factory,division,productCount,
rank() over(partition by factory order by productCount DESC) as rnk
from cte
)
select factory,divsion from cte2 where rnk = 1

