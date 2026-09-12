-- Revenue and delivery performance by customer state and delivery outcome.
--
-- Grain: one row per customer state + delivery outcome.
--
-- Business question:
-- Which high-revenue markets have the greatest delivery risk?

with order_delivery as (

    select
        f.order_id,
        c.customer_state,
        f.delivery_status,
        f.order_revenue

    from {{ ref('fact_orders') }} as f

    inner join {{ ref('dim_customer') }} as c
        on f.customer_id = c.customer_id

    where c.customer_state is not null

),

top_states as (

    select
        customer_state,
        sum(order_revenue) as total_revenue

    from order_delivery

    group by customer_state

    order by total_revenue desc

    limit 10

)

select
    o.customer_state,
    o.delivery_status,
    count(*) as order_count,
    sum(o.order_revenue) as revenue

from order_delivery as o

inner join top_states as t
    on o.customer_state = t.customer_state

group by
    o.customer_state,
    o.delivery_status

order by
    sum(o.order_revenue) desc