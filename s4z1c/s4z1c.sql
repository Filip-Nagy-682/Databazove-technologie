-- Active: 1790280629501@@127.0.0.1@5432@retail

-- Úloha 1 --------------------------------------------------------------------

-- 1. Vytvorenie databázy
CREATE DATABASE retail;

-- 2. Vytvorenie tabuľky retail_sales
CREATE TABLE retail_sales(
    invoice_no      VARCHAR(20),
    stock_code      VARCHAR(50),
    description     TEXT,
    quantity        INT,
    invoice_date    TIMESTAMP,
    unit_price      NUMERIC(10, 2),
    customer_id     INT,
    country         VARCHAR(100)
);

-- 5. Overenie importovaných dát
SELECT *
FROM retail_sales;

-- Úloha 2 --------------------------------------------------------------------

SELECT customer_id, invoice_no, invoice_date, quantity, unit_price, quantity * unit_price AS revenue, SUM(quantity * unit_price) OVER(
    PARTITION BY customer_id
    ORDER BY invoice_date
    RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
) FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY (customer_id, invoice_date);