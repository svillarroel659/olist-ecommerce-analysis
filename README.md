# Olist-ecommerce-analysis
## Overview
This project analyzes the Brazilian E-Commerce Public Dataset by Olist using PostgreSQL.
The goal of the project was to explore sales performance, customer behavior, product and seller performance, geographic patterns, delivery performance, and customer retention using SQL.
The analysis also includes RFM customer segmentation and cohort analysis to better understand customer value, purchasing behavior, and repeat activity over time.

## Data
The dataset contains information from the Olist Brazilian e-commerce marketplace, including:

- Customers

- Orders

- Order items

- Products

- Sellers

- Payments

- Customer reviews

- Product category translations

- Geolocation data

The tables were imported into PostgreSQL and connected using primary and foreign key relationships.

Before beginning the analysis, the data was checked for:

- Missing values

- Duplicate records

- Invalid relationships between tables

- Unusual numeric values

- Date inconsistencies

- Geolocation duplicates

Blank review comments were also standardized as NULL values to improve consistency when handling missing data.

## Analysis

**Sales Analysis**

Sales performance was analyzed using:

- Total orders and revenue

- Average order value

- Revenue by payment type

- Monthly revenue and order volume

- Month-over-month revenue growth

**Product Analysis**

Product performance was evaluated through:

- Top product categories by items sold

- Product revenue by category

- Average item price

- Freight costs

- Total order-item value

**Seller Analysis**

Seller performance was examined using:

- Top sellers by product revenue

- Number of items sold

- Number of distinct orders

- Average item price

- Overall seller revenue ranking

- Seller ranking within each state

**Customer Analysis**

Customer purchasing behavior was explored through:

- Highest-value customers

- Average customer spending

- Purchase frequency

- One-time versus repeat customers

- Repeat customer rate

**RFM Customer Segmentation**

RFM analysis was used to segment customers based on:

- Recency: Days since the customer's most recent purchase

- Frequency: Number of distinct orders placed

- Monetary: Total amount spent

Because the dataset is historical, recency was calculated relative to one day after the latest delivered order rather than the current date.

Recency and monetary values were scored using quintiles with NTILE(). Frequency was scored using custom thresholds because the customer distribution was heavily concentrated among one-time buyers.

Customers were then grouped into segments including:

- Champions

- Loyal Customers

- Potential Loyalists

- New Customers

- At Risk

- Lost Customers

- Other

**Geographic Analysis**

Geographic patterns were analyzed through:

- Customer distribution by state

- Revenue by customer state

- Average order value by state

- Revenue per customer

- Seller distribution by state

- Same-state versus interstate commerce

**Delivery and Review Analysis**

Delivery performance was compared with customer satisfaction using:

- On-time versus late delivery rates

- Average review score by delivery status

- Late-delivery severity

- Average delivery time by review score

- Low-review rates for on-time and late deliveries

**Cohort Analysis**

Customers were grouped into cohorts based on the month of their first delivered purchase.

The analysis measured:

- Customer cohort assignment

- Monthly customer activity

- Months since first purchase

- Active customers by cohort

- Monthly customer retention rates

## SQL Techniques

The project uses a range of SQL techniques, including:

- JOIN and LEFT JOIN

- Common Table Expressions (CTEs)

- Aggregate functions

- Conditional aggregation with FILTER

- CASE statements

- Subqueries

- Date manipulation with DATE_TRUNC and EXTRACT

- Window functions

- NTILE()

- RANK()

- PARTITION BY

- LAG()

- Distinct customer and order calculations

- Cohort and retention calculations

## Data Availability

This project uses the Brazilian E-Commerce Public Dataset by Olist.

The original CSV files are not included in this repository. They can be downloaded from the publicly available Olist dataset and imported into PostgreSQL using the table structure provided in 01_database_setup.sql.

## Next Steps

The next stage of the project will extend the SQL analysis into Python for additional data exploration and visualization.

Selected results will also be used to build an interactive dashboard highlighting key sales, customer, product, geographic, and retention metrics.
