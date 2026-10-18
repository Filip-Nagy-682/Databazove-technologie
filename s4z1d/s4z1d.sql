-- Active: 1790280629501@@127.0.0.1@5432@superstore

-- Úloha 1 --------------------------------------------------------------------

WITH ordered_orders AS(
    SELECT c.customer_name, o.order_id, o.order_date, DENSE_RANK() OVER(
        PARTITION BY c.customer_id
        ORDER BY o.order_date DESC
    ) AS order_rank FROM customers c
    INNER JOIN orders o ON o.customer_id = c.customer_id
)
SELECT * FROM ordered_orders
WHERE order_rank <= 2;

-- Úloha 2 --------------------------------------------------------------------

WITH customer_total_profits AS(
    SELECT  c.region, c.customer_id, SUM(o.profit) AS total_profit FROM customers c
    INNER JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
),
ranked_total_profits AS(
    SELECT *, RANK() OVER(
        PARTITION BY region
        ORDER BY total_profit DESC
    ) AS profit_rank, DENSE_RANK() OVER(
        PARTITION BY region
        ORDER BY total_profit DESC
    ) AS profit_dense_rank FROM customer_total_profits
)
SELECT * FROM ranked_total_profits;