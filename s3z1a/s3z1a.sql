-- Active: 1791371952571@@127.0.0.1@5432@superstore

-- Úloha 1 --------------------------------------------------------------------

CREATE VIEW high_value_customers AS
SELECT c.customer_id, c.customer_name, SUM(o.sales) AS "total_sales" FROM customers c
INNER JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING SUM(o.sales) > 2000;

-- Úloha 2 --------------------------------------------------------------------

CREATE VIEW regional_monthly_sales AS
SELECT c.region, DATE_TRUNC('month', o.order_date), SUM(o.sales) AS "monthly_sales" FROM customers c
INNER JOIN orders o ON o.customer_id = c.customer_id
GROUP BY DATE_TRUNC('month', o.order_date), c.region
HAVING c.region = 'West';