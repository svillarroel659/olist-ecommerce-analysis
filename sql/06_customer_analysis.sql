-- CUSTOMER ANALYSIS
/*
Examines customer spending, purchase frequency, repeat behavior,
and customer value based on purchasing activity.
*/

-- Highest-Value Customers
/*
Identifies customers with the highest total spending.
*/

select 
	c.customer_unique_id,
	count(distinct o.order_id) as total_orders,
	sum(op.payment_value) as total_spent

from customers c
join orders o
	on c.customer_id = o.customer_id
join order_payments op
	on o.order_id = op.order_id

group by c.customer_unique_id
order by total_spent desc
limit 20;

-- Average Spend per Customer
/*
Calculates the average total amount spent across all customers.
*/

select
	round(avg(customer_total), 2) as average_customer_spend

from (
	select
		c.customer_unique_id,
		sum(op.payment_value) as customer_total
	
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	join order_payments op
		on o.order_id = op.order_id
	
	group by c.customer_unique_id
) customer_spending;

-- Customers by Purchase Frequency
/*
Identifies customers with the highest number of distinct orders.
*/

select 
	c.customer_unique_id,
	count(distinct(o.order_id)) as total_orders

from customers c
join orders o
	on c.customer_id = o.customer_id 

group by c.customer_unique_id
order by total_orders desc
limit 20;

-- Repeat Customer Rate
/*
Compares one-time customers with customers who placed multiple orders.
*/

with customer_orders as(
	select
		c.customer_unique_id,
		count(distinct o.order_id) as total_orders
	
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	
	group by c.customer_unique_id
)

select
	count(*) as total_customers,
	count(*) filter (where total_orders = 1) as one_time_customer,
	count(*) filter (where total_orders > 1) as repeat_customer,
	round(
		100.0 * count(*) filter (where total_orders > 1)
		/ count(*),
		2) as repeat_customers_rate_pct

from customer_orders;

	