-- RFM CUSTOMER ANALYSIS
/*
Segments customers using Recency, Frequency, and Monetary value
to identify differences in purchasing behavior and customer value.
*/

-- RFM Metrics
/*
Since the Olist dataset is historical, recency is measured relative
to one day after the latest delivered order rather than today's date.
*/

with reference_date as (
	select 
		max(order_purchase_timestamp) :: date + 1 as snapshot_date
	
	from  orders
	where order_status = 'delivered'
),

customer_rfm as (
	select 
		c.customer_unique_id,
		rd.snapshot_date - max(o.order_purchase_timestamp) :: date as recency,
		
		count(distinct o.order_id) as frequency,
		sum(op.payment_value) as monetary
	
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	join order_payments op
		on o.order_id = op.order_id
	cross join reference_date rd
	
	where o.order_status = 'delivered'
	group by 
		c.customer_unique_id,
		rd_snapshot_date
)
	
select 
	customer_unique_id,
	recency,
	frequency,
	round(monetary, 2) as monetary

from customer_rfm
order by monetary desc;

-- RFM Distribution
/*
Examines the range and average of each RFM metric before scoring.
*/

with reference_date as (
	select
		max(order_purchase_timestamp) :: date + 1 as snapshot_date
	
	from orders
	where order_status = 'delivered'
),

customer_rfm as (
	select
		c.customer_unique_id,
		rd.snapshot_date - max(o.order_purchase_timestamp)::date as recency,
		count(distinct o.order_id) as frequency,
		sum(op.payment_value) as monetary
	
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	join order_payments op
		on o.order_id = op.order_id
	cross join reference_date as rd
	
	where o.order_status = 'delivered'
	group by 
		c.customer_unique_id,
		rd.snapshot_date
)

select 
	min(recency) as min_recency,
	round(avg(recency), 2) as avg_recency,
	max(recency) as max_recency,
	
	min(frequency) as min_frequency,
	round(avg(frequency), 2) as avg_frequency,
	max(frequency) as max_frequency,
	
	round(min(monetary),2) as min_monetary,
	round(avg(monetary), 2) as avg_monetary,
	round(max(monetary), 2) as max_monetary
	
from customer_rfm;

-- Customer Frequency Distribution
/*
Most Olist customers purchase only once, making frequency highly skewed.
This distribution is used to choose a custom frequency scoring method.
*/

with customer_frequency as (
	select 
 		c.customer_unique_id,
 		count(distinct o.order_id) as frequency
 	
 	from customers c
 	join orders o
 		on c.customer_id = o.customer_id
 	
 	where o.order_status = 'delivered'
 	group by c.customer_unique_id
)

select 
	frequency,
	count(*) as customer_count

from customer_frequency
group by frequency
order by frequency;

-- RFM Scoring
/*
Recency and monetary value are divided into quintiles.
Frequency uses custom thresholds because most customers placed only
one order, making quintile-based scoring inappropriate for this metric.
*/

with reference_date as (
	select
		max(order_purchase_timestamp) :: date + 1 as snapshot_date
	
	from orders
	where order_status = 'delivered'
),

customer_rfm as (
	select
		c.customer_unique_id,
		rd.snapshot_date - max(o.order_purchase_timestamp) :: date as recency,
		count(distinct o.order_id) as frequency,
		sum(op.payment_value) as monetary
		
		from customers c
		join orders o
			on c.customer_id = o.customer_id
		join order_payments op
			on o.order_id = op.order_id
		cross join reference_date rd
			
		where order_status = 'delivered'
		group by 
			c.customer_unique_id,
			rd.snapshot_date
		
),

rfm_scores as (
	select
		customer_unique_id,
		recency,
		frequency,
		monetary,
		
		ntile(5) over (
			order by recency desc
		) as r_score,
		
		case
			when frequency = 1 then 1
			when frequency = 2 then 3
			when frequency = 3 then 4
			when frequency >= 4 then 5
		end as f_score,
		
		ntile(5) over (
			order by monetary 
		) as m_score
		
	from customer_rfm
)

select
	customer_unique_id,
	recency,
	frequency,
	round(monetary, 2) as monetary,
	r_score,
	f_score,
	m_score
	
from rfm_scores
order by
	r_score desc,
	f_score desc,
	m_score desc;

-- RFM Customer Segmentation
/*
Assigns behavioral segments using combinations of recency,
frequency, and monetary scores.
*/

with reference_date as (
	select
		max(order_purchase_timestamp) :: date + 1 as snapshot_date
	from orders
	where order_status = 'delivered'
),

customer_rfm as (
	select
		c.customer_unique_id,
		rd.snapshot_date - max(o.order_purchase_timestamp) :: date as recency,
		count(distinct o.order_id) as frequency,
		sum(op.payment_value) as monetary
		
		from customers c 
		join orders o
			on c.customer_id = o.customer_id 
		join order_payments op
			on o.order_id = op.order_id
		cross join reference_date rd
		
		where order_status = 'delivered'
		group by 
			c.customer_unique_id,
			rd.snapshot_date
),

rfm_scores as (
	select
		customer_unique_id,
		recency,
		frequency,
		monetary,
		
		ntile(5) over (
			order by recency desc
		) as r_score,
		
		case
			when frequency = 1 then 1
			when frequency = 2 then 3
			when frequency = 3 then 4
			when frequency >= 4 then 5
		end as f_score,
		
		ntile(5) over (
			order by monetary
		) as m_score
		
	from customer_rfm	
	
),

rfm_segments as (
	select
		*,
		
		case
			when r_score >= 4
				and f_score >= 4
				and m_score >= 4
				then 'Champions'
				
			when r_score >= 4
				and f_score = 3
				then 'Potential Loyalists'
				
			when r_score >= 3
				and f_score >= 3
				then 'Loyal Customers'
				
			when r_score >= 4
				and f_score = 1
				then 'New Customers'
				
			when r_score <= 2
				and f_score >= 3
				then 'At risk'
				
			when r_score <= 2
				and f_score = 1
				then 'Lost Customers'
				
			else 'Other'
		
		end as customer_segment
		
	from rfm_scores
		
)

select
	customer_unique_id,
	recency,
	frequency,
	monetary,
	r_score,
	f_score,
	m_score,
	customer_segment

from rfm_segments
order by 
	r_score desc,
	f_score desc,
	m_score desc;

-- RFM Segment Summary
/*
Compares customer count, purchasing behavior, and revenue
across the final RFM customer segments.
*/

with reference_date as (
	select
		max(order_purchase_timestamp) :: date + 1 as snapshot_date
	
	from orders
	where order_status = 'delivered'
),

customer_rfm as (
	select
		c.customer_unique_id,
		rd.snapshot_date - max(o.order_purchase_timestamp) :: date as recency,
		count(distinct o.order_id) as frequency,
		sum(op.payment_value) as monetary
		
	from customers c
	join orders o
		on c.customer_id = o.customer_id
	join order_payments op
		on o.order_id = op.order_id
	cross join reference_date rd
	
	where o.order_status = 'delivered'
	group by 
		c.customer_unique_id,
		rd.snapshot_date
),

rfm_scores as (
	select
		*,
		
		ntile(5) over (
			order by recency desc
		) as r_score,
		
		case
			when frequency = 1 then 1
			when frequency = 2 then 3
			when frequency = 3 then 4
			when frequency >= 4 then 5
		end as f_score,
		
		ntile(5) over (
			order by monetary
		) as m_score
	
	from customer_rfm
	order by 
		r_score desc,
		f_score desc,
		m_score desc
),

rfm_segments as (
	select *,
	
		case
			when r_score >= 4
				and f_score >= 4
				and m_score >= 4
				then 'Champions'
				
			when r_score >= 4
				and f_score = 3
				then 'Potential Loyalists'
				
			when r_score >= 3
				and f_score >= 3
				then 'Loyal Customers'
				
			when r_score >= 4
				and f_score = 1
				then 'New Customers'
				
			when r_score <= 2
				and f_score >= 3
				then 'At Risk'
				
			when r_score <= 2
				and f_score = 1
				then 'Lost Customers'
				
			else 'Other'
					
		end as customer_segment
		
	from rfm_scores
)

select
	customer_segment,
	count(*) as customer_count,
	round(avg(recency), 1) as avg_recency,
	round(avg(frequency), 2) as avg_frequency,
	round(avg(monetary), 2) as avg_monetary,
	round(sum(monetary), 2) as total_revenue
	
from rfm_segments
group by customer_segment
order by total_revenue desc;

