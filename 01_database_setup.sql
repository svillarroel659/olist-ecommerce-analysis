--- DATABASE SETUP
/*
Creates the core tables for the Olist e-commerce dataset and defines
primary and foreign key relationships between them.
*/


-- Customers
create table customers(
customer_id varchar(32) primary key,
customer_unique_id varchar(32) not null,
customer_zip_code_prefix integer,
customer_city varchar(100),
customer_state varchar(4)
);

-- Products
create table products(
product_id varchar(32) primary key,
product_category_name varchar(100),
product_name_lenght integer,
product_description_lenght integer,
product_photos_qty integer,
product_weight_g integer,
product_length_cm integer,
product_height_cm integer,
product_width_cm integer
);

-- Sellers
create table sellers(
seller_id varchar(32) primary key,
seller_zip_code_prefix integer,
seller_city varchar(100),
seller_state varchar(4)
);

-- Product Category Translation
create table product_category_translation(
product_category_name varchar(100) primary key,
product_category_name_english varchar(100)
);

-- Geolocation
create table geolocation(
geolocation_zip_code_prefix integer,
geolocation_lat double precision,
geolocation_lng double precision,
geolocation_city varchar(100),
geolocation_state varchar(4)
);

-- Orders
create table orders(
order_id varchar(32) primary key,
customer_id varchar(32) not null,
order_status varchar(32),
order_purchase_timestamp timestamp,
order_approved_at timestamp,
order_delivered_carrier_date timestamp,
order_delivered_customer_date timestamp,
order_estimated_delivery_date timestamp,

foreign key (customer_id)
	references customers(customer_id)
);

-- Order Items
create table order_items(
order_id varchar(32) not null,
order_item_id integer not null,
product_id varchar(32) not null,
seller_id varchar(32) not null,
shipping_limit_date timestamp,
price numeric(10,2),
freight_value numeric(10,2),

primary key (order_id, order_item_id),

foreign key (order_id)
	references orders(order_id),

foreign key (product_id)
	references products(product_id),
	
foreign key (seller_id)
	references sellers(seller_id)
);

-- Order Payments
create table order_payments(
order_id varchar(32) not null,
payment_sequential integer not null,
payment_type varchar(32),
payment_installments integer,
payment_value numeric(10,2),

primary key (order_id, payment_sequential),

foreign key (order_id)
	references orders(order_id)
);

-- Order Reviews
create table order_reviews (
    review_id text not null,
    order_id varchar(32) not null,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp,
    review_answer_timestamp timestamp,

    primary key (review_id, order_id),

    foreign key (order_id)
        references orders(order_id)
);

