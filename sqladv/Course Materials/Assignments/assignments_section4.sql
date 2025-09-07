-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Window function basics

-- View the orders table
select * from orders;

-- View the columns of interest
select customer_id,order_id,transaction_id from orders;

-- For each customer, add a column for transaction number
select customer_id,order_id,transaction_id,
row_number() over(partition by customer_id) as transactionNumber
from orders
order by customer_id,transaction_id ;

-- ASSIGNMENT 2: Row Number vs Rank vs Dense Rank

-- View the columns of interest
select order_id,product_id,units from orders;

-- Try ROW_NUMBER to rank the units
select order_id,product_id,units,
row_number() over(partition by order_id order by units) as rn
from orders;

-- For each order, rank the products from most units to fewest units
-- If there's a tie, keep the tie and don't skip to the next number after
select order_id,product_id,units,
dense_rank() over(partition by order_id order by units DESC) as dr
from orders
order by order_id,dr;

-- Check the order id that ends with 44262 from the results preview
select order_id,product_id,units,
dense_rank() over(partition by order_id order by units DESC) as dr
from orders
where order_id like '%44262'
order by order_id,dr;

-- ASSIGNMENT 3: First Value vs Last Value vs Nth Value

-- View the rankings from the last assignment
select order_id,product_id,units,
dense_rank() over(partition by order_id order by units DESC) as dr
from orders
where order_id like '%44262'
order by order_id,dr;

-- Add a column that contains the 2nd most popular product
select order_id,product_id,units,
nth_value(product_id,2) over(partition by order_id order by units DESC) as secondMost
from orders
order by order_id,secondMost;

-- Return the 2nd most popular product for each order
select * from (
select order_id,product_id,units,
nth_value(product_id,2) over(partition by order_id order by units DESC) as secondMost
from orders
order by order_id,secondMost
) as t
where product_id = secondMost;
-- Alternative using DENSE RANK

-- Add a column that contains the rankings
select order_id,product_id,units,
dense_rank() over(partition by order_id order by units DESC) as secondMost
from orders
order by order_id,secondMost

-- Return the 2nd most popular product for each order
select * from (
select order_id,product_id,units,
dense_rank() over(partition by order_id order by units DESC) as secondMost
from orders
order by order_id,secondMost
) as t
where secondMost = 2;

-- ASSIGNMENT 4: Lead & Lag

-- View the columns of interest
select customer_id,order_id,product_id,units from orders;

-- For each customer, return the total units within each order
select customer_id,order_id,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id;

-- Add on the transaction id to keep track of the order of the orders
select customer_id,order_id,min(transaction_id) as minTrans,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id;

-- Turn the query into a CTE and view the columns of interest
with t as (
select customer_id,order_id,min(transaction_id) as minTrans,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id) 
select * from t;

-- Create a prior units column
with t as (
select customer_id,order_id,min(transaction_id) as minTrans,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id)
select customer_id,order_id,totalUnits,
	lag(totalUnits)over(partition by customer_id order by minTrans) as priorUnits
 from t;
-- For each customer, find the change in units per order over time
with t as (
select customer_id,order_id,min(transaction_id) as minTrans,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id)
select customer_id,order_id,totalUnits,
	lag(totalUnits)over(partition by customer_id order by minTrans) as priorUnits,
    totalUnits - lag(totalUnits)over(partition by customer_id order by minTrans) as unitsDiff
 from t;


-- two cts
with t as (
			select customer_id,order_id,min(transaction_id) as minTrans,sum(units) as totalUnits from orders
			group by customer_id,order_id
			order by customer_id),
	c as (
			select customer_id,order_id,totalUnits,
			lag(totalUnits)over(partition by customer_id order by minTrans) as priorUnits
 from t
    )
   select customer_id,order_id,totalUnits,priorUnits, totalUnits- priorUnits as unitsDiff from c ;
-- ASSIGNMENT 5: NTILE

-- Calculate the total amount spent by each customer


-- View the data needed from the orders table


-- View the data needed from the products table


-- Combine the two tables and view the columns of interest

        
-- Calculate the total spending by each customer and sort the results from highest to lowest


-- Turn the query into a CTE and apply the percentile calculation


-- Return the top 1% of customers in terms of spending


