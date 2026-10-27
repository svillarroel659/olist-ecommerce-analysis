-- PRODUCT ANALYSIS
/*
Examines product category popularity, order volume, pricing,
revenue, and freight costs across the Olist marketplace.
*/

-- Top Product Categories by Items Sold
/*
Identifies the most frequently purchased product categories.
*/

select
	coalesce(
	pct.product_category_name_english,
	p.product_category_name
	) as category,
	count(*) as items_sold

from order_items oi
join products p
	on oi.product_id = p.product_id
left join product_category_translation pct
	on p.product_category_name = pct.product_category_name

group by category
order by items_sold desc
limit 10;

-- Top Product Categories by Revenue
/*
Compares sales volume, order count, product revenue, average item price,
freight costs, and total transaction value across product categories.
*/


select
	coalesce(
	pct.product_category_name_english,
	p.product_category_name
	) as category,
	
	count(*) as items_sold,
	count(distinct oi.order_id) as total_orders,
	round(sum(oi.price), 2) as product_revenue,
	round(avg(oi.price), 2) as avg_item_price,
	round(sum(oi.freight_value), 2) as total_freight_value,
	round(sum(oi.price + oi.freight_value), 2) as total_order_item_value
	
from order_items oi
join products p
	on oi.product_id = p.product_id
left join product_category_translation pct
	on p.product_category_name = pct.product_category_name

group by category 
order by product_revenue desc
limit 10;

	