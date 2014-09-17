SELECT /*+ leading(o,c,oi) parallel(2) pq_distribute(c hash,hash) */
    c.customer_id
  , c.cust_first_name
  , c.cust_last_name
  , c.credit_limit
  , o.order_mode
  , avg(oi.unit_price)
FROM
    customers   c
  , orders      o
  , order_items oi
WHERE
-- join
    c.customer_id = o.customer_id
AND o.order_id    = oi.order_id
-- filter
AND o.order_mode = 'direct'
GROUP BY
    c.customer_id
  , c.cust_first_name
  , c.cust_last_name
  , c.credit_limit
  , o.order_mode
HAVING
    sum(oi.unit_price) > c.credit_limit * 1000
/

