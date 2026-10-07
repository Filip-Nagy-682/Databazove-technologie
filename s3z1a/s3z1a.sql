-- Active: 1791371952571@@127.0.0.1@5432@superstore

-- Úloha 1 --------------------------------------------------------------------

CREATE VIEW high_value_customers AS
SELECT c.customer_id, c.customer_name, SUM(o.sales) AS "total_sales" FROM customers c
INNER JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING SUM(o.sales) > 2000;