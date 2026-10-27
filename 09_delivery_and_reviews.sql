-- DELIVERY AND REVIEW ANALYSIS
/*
Examines delivery performance and its relationship with customer
satisfaction, including late-delivery rates and review scores.
*/

-- Delivery Performance
/*
Measures how often delivered orders arrived on or before
the estimated delivery date.
*/

with delivery_status as (
    select
        order_id,
        case
            when order_delivered_customer_date <= order_estimated_delivery_date
                then 'On Time'
            else 'Late'
        end as delivery_status
    from orders
    where order_status = 'delivered'
      and order_delivered_customer_date is not null
      and order_estimated_delivery_date is not null
)

select
    delivery_status,
    count(*) as order_count,
    round(
        100.0 * count(*) / sum(count(*)) over (),
        2
    ) as percentage_of_orders

from delivery_status
group by delivery_status
order by order_count;

-- Delivery Performance and Review Scores
/*
Compares average customer ratings for on-time and late deliveries.
*/

select
	case
		when o.order_delivered_customer_date <= o.order_estimated_delivery_date
			then 'On time'
		else 'Late'
	end as delivery_status,
	count(*) as review_count,
	round(avg(r.review_score), 2) as average_review_score
	
from orders o
join order_reviews r
	on o.order_id = r.order_id
	
where o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
	and r.review_score is not null

group by delivery_status;
	
-- Late Delivery Severity
/*
Groups late orders by the number of days delayed and compares
customer review scores across different levels of lateness.
*/

with late_orders as (
	select
		o.order_id,
		r.review_score,
		
		order_delivered_customer_date :: date -
			order_estimated_delivery_date :: date as days_late
	from orders o
	join order_reviews r
		on o.order_id = r.order_id
	
	where o.order_status = 'delivered'
		and o.order_delivered_customer_date is not null
		and o.order_estimated_delivery_date is not null
		and r.review_score is not null
		and o.order_delivered_customer_date > o.order_estimated_delivery_date
)

select 
	case 
		when days_late <= 3 then '1-3 Days Late'
		when days_late <= 7 then '4-7 Days Late' 
		when days_late <= 14 then '8-14 Days Late'
		else '15+ Days Late'
	end as lateness_group,
	
	count(*) as orders,
	round(avg(review_score), 2) as average_review_score
	
from late_orders
group by lateness_group
order by min(days_late);

-- Average Delivery Time by Review Score
/*
Examines whether longer delivery times are associated with
lower customer ratings.
*/

select
    r.review_score,
    count(*) as orders,
    round(
        avg(
            o.order_delivered_customer_date::date
            - o.order_purchase_timestamp::date
        ),
        2
    ) as average_delivery_days

from orders o
join order_reviews r
    on o.order_id = r.order_id

where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null
  and r.review_score is not null

group by r.review_score
order by r.review_score;

-- Delivery and Review Summary
/*
Summarizes delivery time, customer ratings, and low-review rates
for on-time and late deliveries.
*/

select
	case
		when o.order_delivered_customer_date <= o.order_estimated_delivery_date
			then 'On time'
		else 'Late'
	end as delivery_status,
	
	count(distinct o.order_id) as total_orders,
	
	round(
		avg(
			o.order_delivered_customer_date :: date
			- o.order_purchase_timestamp :: date
		),
		2
	) as avg_delivery_days,
	
	round(avg(r.review_score), 2) as avg_review_score,
	
	round(
		100.0 * count(*) filter (where r.review_score <= 2)
		/ count(*),
		2
	) as low_review_rate_pct
	
from orders o
join order_reviews r
	on o.order_id = r.order_id
	
where o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
	and r.review_score is not null
	
group by delivery_status;

	
		