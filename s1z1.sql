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