-- Active: 1790280629501@@127.0.0.1@5432@superstore

-- Úloha 1 --------------------------------------------------------------------

-- 1. Vytvorenie databázy
CREATE DATABASE superstore;

-- 2. Vytvorenie tabuľky customers
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

-- 3. Vytvorenie tabuľky products
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

-- 4. Vytvorenie tabuľky orders
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    sales NUMERIC(18, 2),
    quantity INT,
    discount NUMERIC(18, 2),
    profit NUMERIC(18, 2),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- 7. Overovanie importovaných dát
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

-- Úloha 2 --------------------------------------------------------------------

SELECT o.order_id, c.customer_name, o.sales FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
WHERE o.sales > 500
ORDER BY o.sales DESC;

-- Úloha 3 --------------------------------------------------------------------

SELECT o.order_id, c.customer_name, p.category, o.sales FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN products p ON p.product_id = o.product_id;

-- Úloha 4 --------------------------------------------------------------------

SELECT c.region, SUM(o.sales) FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.region;

-- Úloha 5 --------------------------------------------------------------------

SELECT p.product_name, SUM(o.sales) FROM products p
LEFT JOIN orders o ON o.product_id = p.product_id
GROUP BY p.product_id;

-- Úloha 6 --------------------------------------------------------------------

SELECT c.customer_name, o.order_id, o.sales FROM customers c
FULL OUTER JOIN orders o ON o.customer_id = c.customer_id;

-- Úloha 7 --------------------------------------------------------------------

SELECT c.region, SUM(o.sales) FROM customers c
INNER JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.region;

-- Úloha 8 --------------------------------------------------------------------

SELECT c.customer_name, COUNT(o.order_id) FROM customers c
LEFT JOIN orders o on o.customer_id = c.customer_id
GROUP BY c.customer_id;