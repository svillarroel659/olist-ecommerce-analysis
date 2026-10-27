-- GEOGRAPHIC ANALYSIS
/*
Examines the geographic distribution of customers and sellers,
regional sales performance, and interstate commerce across Brazil.
*/

-- Customer Distribution by State

select	
	customer_state,
	count(distinct customer_unique_id) as unique_customers

from customers
group by customer_state
order by unique_customers desc;

-- Customer Sales Performance by State
/*
Compares customer count, order volume, revenue, average order value,
and revenue per customer across states.
*/

select
	c.customer_state,
	count(distinct c.customer_unique_id) as unique_customers,
	count(distinct o.order_id) as total_orders,
	round(sum(op.payment_value), 2) as total_revenue,
	round(
		sum(op.payment_value) / count(distinct o.order_id), 2
	) as average_order_value,
	round(
		sum(op.payment_value)
		/count(distinct c.customer_unique_id),
		2) as revenue_per_customer
	
from customers c
join orders o
	on c.customer_id = o.customer_id 
join order_payments op
	on o.order_id = op.order_id

where o.order_status = 'delivered'
group by c.customer_state
order by total_revenue desc;


-- Seller Distribution and Revenue by State
/*
Shows where sellers are concentrated and how much product revenue
each seller state generates.
*/

select
	s.seller_state,
	count(distinct s.seller_id) as total_sellers,
	count(distinct oi.order_id) as total_orders,
	round(sum(oi.price), 2) as product_revenue

from sellers s
join order_items oi
	on s.seller_id = oi.seller_id 

group by s.seller_state
order by product_revenue desc;
	
-- Interstate vs. Intrastate Commerce
/*
Compares purchases where the seller and customer are located in the
same state with purchases that cross state borders.
*/

select 

	case
		when c.customer_state = s.seller_state
			then 'Same State'
		else 'Different State'
	end as seller_customer_location,
	count(*) as item_count,
	count(distinct oi.order_id) as total_orders,
	round(sum(oi.price), 2) as product_revenue
	
from order_items oi
join orders o
	on oi.order_id = o.order_id
join customers c
	on o.customer_id = c.customer_id
join sellers s
	on oi.seller_id = s.seller_id

where o.order_status = 'delivered'
group by seller_customer_location
order by product_revenue desc;

	
	