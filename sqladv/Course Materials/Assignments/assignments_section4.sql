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
select customer_id,order_id,units from orders;

-- For each customer, return the total units within each order
select customer_id,order_id,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id;

-- Add on the transaction id to keep track of the order of the orders
select customer_id,order_id,min(transaction_id),sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id,transId;

-- Turn the query into a CTE and view the columns of interest
with t as ( 
select customer_id,order_id,min(transaction_id) as transId,sum(units) as totalUnits from orders
group by customer_id,order_id
order by customer_id,transId
)
select customer_id,order_id,transId,totalUnits from t;


-- Create a prior units column
with t as ( 
select customer_id,order_id,min(transaction_id) as transId,sum(units) as totalUnits
 from orders
group by customer_id,order_id
order by customer_id,transId
)
select customer_id,order_id,transId,totalUnits,
lag(totalUnits) over(partition by customer_id) as priorUnits
 from t
  where customer_id = 11148;
-- For each customer, find the change in units per order over time
with t as ( 
select customer_id,order_id,min(transaction_id) as transId,sum(units) as totalUnits
 from orders
group by customer_id,order_id
order by customer_id,transId
)
select customer_id,order_id,transId,totalUnits,
lag(totalUnits) over(partition by customer_id order by transId) as priorUnits,
totalUnits - lag(totalUnits) over(partition by customer_id order by transId) as unitsDiff
 from t
 where customer_id = 11148;

-- two cts
with t as ( 
select customer_id,order_id,min(transaction_id) as transId,sum(units) as totalUnits
 from orders
group by customer_id,order_id
order by customer_id,transId
),
	c as (
 select customer_id,order_id,transId,totalUnits,
lag(totalUnits) over(partition by customer_id order by transId) as priorUnits
from t
)
select customer_id,order_id,transId,totalUnits,priorUnits,totalUnits - priorUnits as unitsDiff from c
where customer_id = 11148;
-- ASSIGNMENT 5: NTILE

-- Calculate the total amount spent by each customer


-- View the data needed from the orders table
select customer_id,product_id,units from orders;

-- View the data needed from the products table
select product_id,unit_price from products;

-- Combine the two tables and view the columns of interest
select o.customer_id,o.product_id,o.units, p.unit_price from orders o
inner join products p
on p.product_id = o.product_id;
        
-- Calculate the total spending by each customer and sort the results from highest to lowest
select o.customer_id,sum(o.units*p.unit_price) as totalSpend from orders o
inner join products p
on p.product_id = o.product_id
group by customer_id
order by totalSpend DESC;

-- Turn the query into a CTE and apply the percentile calculation
with cte as ( 
select o.customer_id,sum(o.units*p.unit_price) as totalSpend from orders o
inner join products p
on p.product_id = o.product_id
group by o.customer_id
order by totalSpend DESC
)
select customer_id,totalSpend,
ntile(100) over() as pct from cte;



-- Return the top 1% of customers in terms of spending
with cte as ( 
select o.customer_id,sum(o.units*p.unit_price) as totalSpend from orders o
inner join products p
on p.product_id = o.product_id
group by o.customer_id
order by totalSpend DESC
),
 cte2 as(select customer_id,totalSpend,
ntile(100) over(order by totalSpend desc) as pct from cte)
select * from cte2
where pct = 1;


