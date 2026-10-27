-- COHORT ANALYSIS
/*
Groups customers by their first purchase month and measures
how many return in subsequent months.
*/

-- Customer Cohort Assignment
/*
Assigns each customer to the month of their first delivered purchase.
*/

with customer_first_purchase as (
	select 
		c.customer_unique_id,
		
		date_trunc(
			'month',
			min(o.order_purchase_timestamp)
		) as cohort_month
		
	from customers c
	join orders o
		on c.customer_id = o.customer_id
		
	where o.order_status = 'delivered'
	group by c.customer_unique_id
)

select
	*
from customer_first_purchase
order by cohort_month

-- Cohort Activity
/*
Counts the number of active customers from each cohort
in the months following their first purchase.
*/

with customer_first_purchase as (
	select	
		c.customer_unique_id,
		
		date_trunc(
			'month',
			min(o.order_purchase_timestamp)
		) as cohort_month
	
	from customers c
	join orders o
		on c.customer_id = o.customer_id 
	
	where o.order_status = 'delivered'
	group by c.customer_unique_id
	
),

customer_orders as (
	select distinct
		c.customer_unique_id,
		
		date_trunc(
			'month',
			o.order_purchase_timestamp
		) as order_month
		
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	
	where o.order_status = 'delivered'
),

cohort_activity as (
	select
		cfp.customer_unique_id,
		cfp.cohort_month,
		co.order_month,
	
		(
			extract(year from co.order_month)
			- extract(year from cfp.cohort_month)
		) * 12
	
		+
	
		(
			extract(month from co.order_month)
			- extract(month from cfp.cohort_month)
		) as cohort_index
	
	from customer_first_purchase cfp
	join customer_orders co
		on cfp.customer_unique_id = co.customer_unique_id
	
)

select 
	cohort_month,
	cohort_index,
	count(distinct customer_unique_id) as active_customers
from cohort_activity
group by 
	cohort_month,
	cohort_index
order by 
	cohort_month,
	cohort_index;


-- Cohort Retention Rates
/*
Calculates the percentage of customers from each cohort
who return in subsequent months.
*/

with customer_first_purchase as (
	select
		c.customer_unique_id,
		
		date_trunc(
			'month',
			min(o.order_purchase_timestamp)
		) as cohort_month
		
	from customers c
	join orders o
		on c.customer_id = o.customer_id
		
	where o.order_status = 'delivered'
	group by c.customer_unique_id
),

customer_orders as (
	select distinct
		c.customer_unique_id,
		
		date_trunc(
			'month',
			o.order_purchase_timestamp
		) as order_month
		
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	
	where o.order_status = 'delivered'
),

cohort_activity as (
	select
		cfp.customer_unique_id,
		cfp.cohort_month,
		
		(
			extract(year from co.order_month)
			- extract(year from cfp.cohort_month)
		) * 12
		
		+
		
		(
			extract(month from co.order_month)
			- extract(month from cfp.cohort_month)
		) as cohort_index
		
	from customer_first_purchase cfp
	join customer_orders co
		on cfp.customer_unique_id = co.customer_unique_id
		
),

cohort_counts as (
	select
		cohort_month,
		cohort_index,
		count(distinct customer_unique_id) as active_customers
	
	from cohort_activity
	group by
		cohort_month,
		cohort_index
),

cohort_sizes as (
	select
		cohort_month,
		active_customers as cohort_size
	
	from cohort_counts
	where cohort_index = 0
)
		
select 
	cc.cohort_month,
	cc.cohort_index,
	cc.active_customers,
	cs.cohort_size,
	
	round(
		100.0 * cc.active_customers /cs.cohort_size,
		2
	) as retention_rate_pct
	
from cohort_counts cc
join cohort_sizes cs
	on cc.cohort_month = cs.cohort_month
	
order by
	cc.cohort_month,
	cc.cohort_index;
	
