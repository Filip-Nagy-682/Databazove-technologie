-- Active: 1790280629501@@127.0.0.1@5432@retail_sales

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

-- Úloha 8 --------------------------------------------------------------------

-- 1. Vytvorenie databázy
CREATE DATABASE retail_sales;

-- 2. Vytvorenie tabuľky orders
CREATE TABLE orders(
    order_id    VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id  VARCHAR(20) NOT NULL,
    order_date  DATE NOT NULL,
    region      VARCHAR(20) NOT NULL,
    category    VARCHAR(50) NOT NULL,
    ship_mode   VARCHAR(30) NOT NULL,
    sales       NUMERIC(18,2) NOT NULL,
    profit      NUMERIC(18,2) NOT NULL
);

-- 3. Nastavenie dátového formátu databázy
ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

-- 6. Overenie importovaných dát
SELECT *
FROM orders;

-- Úloha 9 --------------------------------------------------------------------

CREATE PROCEDURE get_customer_sales(
    customer_id_ VARCHAR(20)
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    total NUMERIC(18, 2);
    sale_count INT;
BEGIN
    SELECT SUM(sales) FROM orders
    WHERE customer_id = customer_id_
    INTO total;

    SELECT COUNT(sales) FROM orders
    WHERE customer_id = customer_id_
    INTO sale_count;

    RAISE NOTICE 'Customer % has % total sales across % sales', customer_id_, total, sale_count;
END;
$procedure$;

CALL get_customer_sales('CUST00001');

-- Úloha 10 -------------------------------------------------------------------

CREATE PROCEDURE apply_regional_discount(
    region_name VARCHAR(20),
    discount_rate NUMERIC(2, 2)
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - discount_rate)
    WHERE region = region_name;

    RAISE NOTICE 'A discount of % has been applied for % region', discount_rate, region_name;
END;
$procedure$;

SELECT sales FROM orders
WHERE region = 'West';

CALL apply_regional_discount('West', 0.10);

-- Úloha 11 -------------------------------------------------------------------

CREATE PROCEDURE get_sales_between(
    start_date  DATE,
    end_date    DATE
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    total       NUMERIC(18, 2);
BEGIN
    SELECT SUM(sales) FROM orders
    WHERE order_date > start_date AND order_date < end_date
    INTO total;

    RAISE NOTICE 'The sales between % and % add up to %', start_date, end_date, total;
END;
$procedure$;

CALL get_sales_between('2024-01-01', '2024-03-31');