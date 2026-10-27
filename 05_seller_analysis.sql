-- SELLER ANALYSIS
/*
Evaluates seller performance by revenue, order volume, location,
and relative ranking within the marketplace.
*/

-- Top Sellers by Revenue
/*
Identifies the highest-performing sellers based on product sales.
*/

select
    s.seller_id,
    s.seller_city,
    s.seller_state,
    count(*) AS items_sold,
    count(distinct oi.order_id) as total_orders,
    round(avg(oi.price), 2) as average_item_price,
    round(sum(oi.price), 2) as product_revenue
    
from order_items oi
join sellers s
    on oi.seller_id = s.seller_id
    
group by
    s.seller_id,
    s.seller_city,
    s.seller_state
order by product_revenue desc
limit 10;


-- Overall Seller Revenue Ranking
/*
Ranks sellers across the marketplace based on total product revenue.
*/

with seller_revenue as (
    select
        s.seller_id,
        s.seller_city,
        s.seller_state,
        sum(oi.price) as product_revenue
        
    from order_items oi
    join sellers s
        on oi.seller_id = s.seller_id
    group by
        s.seller_id,
        s.seller_state
)

select
    seller_id,
    seller_city,
    seller_state,
    round(product_revenue, 2) as product_revenue,
    
    rank() over (
        order by product_revenue desc
    ) as revenue_rank
    
from seller_revenue
order by revenue_rank
limit 20;

-- Seller Revenue Ranking Within Each State
/*
Compares sellers against others operating in the same state.
*/


with seller_revenue as (
    select
        s.seller_id,
        s.seller_city,
        s.seller_state,
        sum(oi.price) AS product_revenue
        
    from order_items oi
    join sellers s
        on oi.seller_id = s.seller_id
    group by
        s.seller_id,
        s.seller_city,
        s.seller_state
)

select
    seller_id,
    seller_city,
    seller_state,
    round(product_revenue, 2) as product_revenue,
    rank() over (
        partition by seller_state
        order by product_revenue desc
    ) as state_revenue_rank
    
from seller_revenue
order by
    seller_state,
    state_revenue_rank;

