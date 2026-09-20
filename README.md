# E-commerce Analytics Engineering with dbt

## Project Overview

This project was created to practice analytics engineering and dbt using e-commerce order and payment data.

The raw data was first organized into a Staging Layer before being used for analytical modeling.

I then combined order and payment data to build `fct_orders`, which provides the actual payment amount for each order. Based on this order-level model, I created `fct_customer_summary` to analyze the number of orders and total spending by customer.

Data quality tests were also applied using `schema.yml` and validated with `dbt test`.

---

## Data Architecture

```text
Raw Data
    │
    ├── raw_customers
    ├── raw_orders
    └── raw_payments
            │
            ↓
      Staging Layer
            │
    ├── stg_customers
    ├── stg_orders
    └── stg_payments
            │
            ↓
        Mart Layer
            │
       fct_orders
            │
            ↓
   fct_customer_summary

Layer Description
Raw

Original source data used as the starting point for the transformation process.

Staging

Organizes raw data into models that can be used for downstream transformations.

Mart

Provides analytical models designed around specific business questions and analytical use cases.

Data Models
Staging Models
Model	Description
stg_customers	Cleans and organizes customer data
stg_orders	Cleans and organizes order data
stg_payments	Cleans and organizes payment data
fct_orders

Grain: 1 row = 1 order

This model was created to provide the actual payment amount for each order.

stg_orders and stg_payments are joined using order_id so that order and payment information can be analyzed together.

Payment records are aggregated by order_id before joining them to the order data. This allows the final model to maintain an order-level grain.

Key Logic
SUM(amount) to calculate total payment amount per order
GROUP BY order_id to aggregate payments at the order level
LEFT JOIN to retain orders without payment records
COALESCE to convert missing payment amounts from NULL to 0
fct_customer_summary

Grain: 1 row = 1 customer

This model was created to analyze the data at the customer level rather than the order level.

The model groups fct_orders by customer_id and calculates the number of orders and total spending for each customer.

Key Columns
Column	Description
customer_id	Customer identifier
total_orders	Total number of orders per customer
total_spend	Total spending per customer
Key Logic
GROUP BY customer_id to aggregate data at the customer level
COUNT(order_id) to calculate the number of orders
SUM(amount) to calculate total spending
Data Model Grain
Model	Grain	Meaning
stg_orders	1 row = 1 order	One row represents one order
stg_payments	1 row = 1 payment	One row represents one payment record
fct_orders	1 row = 1 order	One row represents one order
fct_customer_summary	1 row = 1 customer	One row represents one customer

Grain defines what a single row represents within a model.

Data Quality

Data quality tests were defined in schema.yml and executed using dbt test.

fct_orders
Column	Tests	Reason
order_id	unique, not_null	Core identifier for each order
customer_id	not_null	Each order should have a customer identifier
order_date	not_null	Order date is required
status	not_null	Order status is required
amount	not_null	Payment amount is required
fct_customer_summary
Column	Tests	Reason
customer_id	unique, not_null	The model grain is one row per customer
total_orders	not_null	Customer-level order count
total_spend	not_null	Customer-level total spending
Key Design Decisions
1. Separate Staging Layer

Raw data was separated from analytical models by introducing a Staging Layer.

This provides a clear separation between source data and downstream analytical models.

2. Aggregate Payments Before Joining

Payment records were aggregated by order_id using SUM(amount) before joining them to the order data.

This allows the final model to maintain an order-level grain.

3. Use LEFT JOIN

A LEFT JOIN was used to retain orders even when no corresponding payment record exists.

When an order has no payment record, the joined payment amount can be NULL. COALESCE is therefore used to represent the missing amount as 0.

4. Create a Customer-Level Summary

fct_orders provides order-level information, while fct_customer_summary provides customer-level metrics.

The customer summary groups the order-level data by customer_id to calculate total orders and total spending.

Lineage

dbt's ref() function was used to define dependencies between models.

raw_orders
     ↓
stg_orders ───────┐
                  ↓
              fct_orders
                  ↑
stg_payments ─────┘
                  │
                  ↓
        fct_customer_summary

fct_customer_summary references fct_orders, while fct_orders references stg_orders and stg_payments.

dbt Validation
dbt parse

Used to validate project structure and SQL/YAML syntax.

dbt run

Used to execute the SQL models and build the models.

dbt test

Used to validate data quality rules defined in schema.yml, including unique and not_null tests.

All models and data quality tests passed successfully.

Tech Stack
SQL
dbt
BigQuery
GitHub
