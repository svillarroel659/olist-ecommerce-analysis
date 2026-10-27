--- SALES ANALYSIS
/*
 * Summarizes overall revenue, average order value, payment method 
 * performance,monthly sales trends, and month-over-month revenue growth.
 */


-- Total orders and revenue

select
	count(distinct order_id) as total_orders,
	round(sum(payment_value),2) as total_revenue
from order_payments;

-- Average Order Value

select 
	round(
		sum(payment_value) / count(distinct order_id),
		2) as average_order_value
from order_payments;

-- Revenue by Payment Type
/*
Compares transaction volume, revenue, and average order value
across different payment methods.
*/

select 
	payment_type,
	count(*) as payment_count,
	count(distinct order_id) as order_count,
	round(sum(payment_value), 2) as total_revenue,
	round(
		sum(payment_value) / count(distinct order_id),
		2) as avg_order_value

from order_payments
group by payment_type
order by total_revenue desc;

-- Monthly Revenue and Order Volume

select
	date_trunc('month', o.order_purchase_timestamp) as month,
	count(distinct o.order_id) as total_orders,
	round(sum(op.payment_value), 2) as revenue,
	round(sum(op.payment_value) / count(distinct o.order_id), 2) as avg_order_value

from orders o
join order_payments op
	on o.order_id = op.order_id
group by month
order by month;

-- Month-over-Month Revenue Growth
/*
Calculates monthly revenue performance and percentage growth
compared with the previous month.
*/

with monthly_sales as (
	select 
		date_trunc('month', o.order_purchase_timestamp) as month,
		count(distinct o.order_id) as total_orders,
		round(sum(op.payment_value), 2) as revenue,
		round(sum(op.payment_value) / count(distinct o.order_id), 2) as avg_order_value
	
	from orders o
	join order_payments op
		on o.order_id = op.order_id
	group by month
)

select
	month,
	total_orders,
	revenue,
	avg_order_value,
	round(lag(revenue) over (order by month), 2) as previous_month_revenue,
	round(
	(
		revenue - lag(revenue) over (order by month)
	) 
	/ nullif(lag(revenue) over(order by month), 0) * 100, 2) as revenue_growth_pct

from monthly_sales
order by month;
