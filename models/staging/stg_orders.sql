Select
    id as order_id,
    user_id as customer_id,
    order_date,
    status
From {{ref('raw_orders')}}
