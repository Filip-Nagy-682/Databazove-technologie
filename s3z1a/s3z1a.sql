-- Active: 1790280629501@@127.0.0.1@5432@superstore

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

-- Úloha 3 --------------------------------------------------------------------

CREATE VIEW analyst_orders AS
SELECT order_id, customer_id, product_id, sales, quantity, discount FROM ORDERS;

-- Úloha 4 --------------------------------------------------------------------

CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Úloha 5 --------------------------------------------------------------------

CREATE INDEX idx_orders_order_date ON orders(order_date);

SELECT DATE_TRUNC('month', order_date), SUM(sales) FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date) ASC;

-- Úloha 6 --------------------------------------------------------------------

CREATE INDEX idx_orders_region_category ON orders(customer_id, order_date);

SELECT * FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
WHERE c.region = 'West';

-- Úloha 7 --------------------------------------------------------------------

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';