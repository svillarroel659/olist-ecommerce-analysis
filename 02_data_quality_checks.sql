--- DATA QUALITY CHECKS
/*
Validates row counts, duplicate records, missing values, key relationships,
numeric ranges, order statuses, date consistency, and geolocation duplicates.
*/

-- Row counts

select 
	count(*) as customer_rows
from customers;


select
	count(*) as product_rows
from products;


select
	count(*) as seller_rows
from sellers;


select 
	count(*) as category_translation_rows
from product_category_translation;


select
	count(*) as geolocation_rows
from geolocation;


select
	count(*) as order_rows
from orders;


select
	count(*) as order_item_rows
from order_items;


select 
	count(*) as payment_rows
from order_payments;


select 
	count(*) as review_rows
from order_reviews;


-- Duplicate checks
/*
Primary keys prevent duplicate IDs, but these queries confirm
that the imported data follows the expected table structure.
*/

select
	customer_id,
	count(*) as duplicate_count
from customers
group by customer_id
having count(*) > 1;


select 
	product_id,
	count(*) as duplicated_rows
from products
group by product_id 
having count(*) > 1;


select 
	seller_id,
	count(*) as duplicated_rows
from sellers
group by seller_id
having count(*) > 1;


select
	order_id,
	count(*) as duplicated_rows
from orders
group by order_id
having count(*) > 1;

-- Missing values

select
	count(*) as total_rows,
	
	count(*) filter (
		where customer_id is null 
		or trim(customer_id) = ''
		) as missing_customer_id,
		
	count(*) filter (
		where customer_unique_id is null
		or trim(customer_unique_id) = ''
		) as missing_unique_id,
		
	count(*) filter (
		where customer_zip_code_prefix is null
		) as missing_zip_code,
		
	count(*) filter (
		where customer_city is null 
		or trim(customer_city) = ''
		) as missing_city,
		
	count(*) filter (
		where customer_state is null 
		or trim(customer_state) = ''
		) as missing_state
from customers;

select
	count(*) as total_rows,
	
	count(*) filter (
		where product_category_name is null 
		or trim(product_category_name) = ''
		) as missing_category_name,
		
	count(*) filter (
		where product_weight_g is null
		) as missing_product_weight,
		
	count(*) filter (
		where product_length_cm is null
		) as missing_product_length,
		
	count(*) filter (
		where product_height_cm  is null
		) as missing_product_height,
		
	count(*) filter (
		where product_width_cm is null
		) as missing_product_width
from products;

select 
	count(*) as total_rows,
	
	count(*) filter (
		where order_status is null 
		or trim(order_status) = ''
		) as missing_order_status,
		
	count(*) filter (
		where order_purchase_timestamp is null
		) as missing_purchase_date,
		
	count(*) filter (
		where order_approved_at is null
		) as missing_approved_date,
		
    count(*) filter (
    	where order_delivered_carrier_date is null
    	) as missing_carrier_date,
    	
    count(*) filter (
    	where order_delivered_customer_date is null
    	) as missing_customer_delivery_date,
    	
    count(*) filter (
    	where order_estimated_delivery_date is null
    	) as missing_estimated_date
from orders;

-- Review comment cleaning
/*
Standardizes blank review comments as NULL values.
*/

update order_reviews
set review_comment_title = null
where trim(review_comment_title) = '';

update order_reviews
set review_comment_message = null
where trim(review_comment_message) = '';

select
    count(*) AS reviews_without_comments
from order_reviews
where review_comment_message is null;

-- Foreign key checks
/*
Verifies that relationship fields match valid records in their parent tables.
*/

select
	count(*) as unmatched_customers
from orders o 
left join customers c
	on o.customer_id = c.customer_id
where c.customer_id is null;

select 
	count(*) as unmatched_orders
from order_items oi
left join orders o 
	on oi.order_id = o.order_id
where o.order_id is null;

select 
	count(*) as unmatched_products
from order_items oi
left join products p
	on oi.product_id = p.product_id
where p.product_id is null;

select 
	count(*) as unmatched_sellers
from order_items oi
left join sellers s
	on oi.seller_id = s.seller_id 
where s.seller_id is null;

select 
	count(*) as unmatched_payment_orders
from order_payments op
left join orders o
	on op.order_id = o.order_id 
where o.order_id is null;

select 
	count(*) as unmatched_review_orders
from order_reviews r
left join orders o
	on r.order_id = o.order_id 
where o.order_id is null;

-- Numeric range checks

select
	min(review_score) as min_review_score,
	max(review_score) as max_review_score
from order_reviews;

select
	min(price) as min_price,
	max(price) as max_price,
	round(avg(price),2) as avg_price
from order_items;

select 
	min(freight_value) as min_freight,
	max(freight_value) as max_freight,
	round(avg(freight_value),2) as avg_freight
from order_items;

select 
	min(payment_value) as min_payment,
	max(payment_value) as max_payment,
	round(avg(payment_value),2) as avg_payment
from order_payments;

-- Order status distribution

select 
	order_status,
	count(*) as order_count
from orders
group by order_status
order by order_count desc;

-- Date consistency checks

select
	count(*) as delivery_before_purchase
from orders
where order_delivered_customer_date < order_purchase_timestamp;

select
	count(*) as estimated_delivery_before_purchase
from orders
where order_estimated_delivery_date < order_purchase_timestamp;

select 
	count(*) as approval_before_purchase
from orders
where order_approved_at < order_purchase_timestamp;

-- Geolocation duplicate check
/*
The geolocation table contains multiple observations for the same ZIP code prefix,
because a ZIP code can appear with different latitude/longitude records.
*/

select
	geolocation_zip_code_prefix,
	count(*) as zip_code_count
from geolocation
group by geolocation_zip_code_prefix
having count(*) > 1
order by zip_code_count desc
limit 10;





