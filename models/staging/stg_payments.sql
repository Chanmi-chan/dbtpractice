Select 
    id as payment_id,
    order_id,
    payment_method,
    amount / 100 as amount
From {{ref('raw_payments')}}
