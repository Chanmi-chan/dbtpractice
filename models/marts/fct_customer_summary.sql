with orders as (
    select * from {{ref('fct_orders')}}
),

final as(
    select 
      customer_id,
      count(order_id) as total_orders,
      sum(amount) as total_spend   
    from orders
    group by 1 )

select * from final
