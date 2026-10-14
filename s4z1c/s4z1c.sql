-- Active: 1791976164089@@127.0.0.1@5432@retail

-- Úloha 1 --------------------------------------------------------------------

-- 1. Vytvorenie databázy
CREATE DATABASE retail;

-- 2. Vytvorenie tabuľky retail_sales
CREATE TABLE retail_sales(
    invoice_no      VARCHAR(20),
    stock_code      VARCHAR(50),
    description     TEXT,
    quantity        INT,
    invoice_date    DATE,
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
) AS revenue_last_14_days FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY (customer_id, invoice_date);

-- Úloha 3 --------------------------------------------------------------------

SELECT stock_code, country, invoice_date, quantity, ROUND(AVG(quantity) OVER(
    PARTITION BY (stock_code, country)
    ORDER BY invoice_date
    RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
), 2) AS avg_quantity_7_days FROM retail_sales
WHERE quantity > 1
ORDER BY (stock_code, country, invoice_date);

-- Úloha 4 --------------------------------------------------------------------

WITH invoices AS(
    SELECT DISTINCT customer_id, invoice_no, invoice_date, LEAD(invoice_date) OVER(
    PARTITION BY customer_id
    ORDER BY invoice_date
    ) AS next_invoice_date FROM retail_sales
)
SELECT *, next_invoice_date - invoice_date AS days_to_next_invoice FROM invoices
WHERE next_invoice_date IS NOT NULL AND next_invoice_date - invoice_date <> 0
ORDER BY next_invoice_date - invoice_date DESC;