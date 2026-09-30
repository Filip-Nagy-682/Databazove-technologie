-- Active: 1790280629501@@127.0.0.1@5432@datacraftinglab_db

-- Úloha 1 --------------------------------------------------------------------

-- 1. Vytvorenie databázy
CREATE DATABASE datacraftinglab_db;

-- 2. Vytvorenie tabuľky flourmills_sales
CREATE TABLE flourmills_sales(
    sales_id            INT PRIMARY KEY,
    sale_date           DATE,
    region              VARCHAR(100),
    state               VARCHAR(100),
    product_category    VARCHAR(100),
    product_name        VARCHAR(150),
    customer_type       VARCHAR(100),
    customer_id         INT,
    quantity_sold       INT,
    unit_price          NUMERIC(18, 2),
    discount_rate       INT,
    payment_method      VARCHAR(100),
    sales_rep           VARCHAR(150),
    warehouse           VARCHAR(100),
    delivery_status     VARCHAR(100),
    order_channel       VARCHAR(100),
    batch_number        INT,
    production_date     DATE,
    total_amount        NUMERIC(18, 2)
);

-- 5. Overovanie importovaných dát
SELECT * FROM flourmills_sales;

-- Úloha 2 --------------------------------------------------------------------

SELECT product_name, total_amount FROM flourmills_sales
WHERE total_amount > (
    SELECT AVG(total_amount) FROM flourmills_sales
);

-- Úloha 3 --------------------------------------------------------------------

SELECT * FROM flourmills_sales
WHERE product_category = (
    SELECT product_category FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC LIMIT 1
)
ORDER BY sales_id ASC;

-- Úloha 4 --------------------------------------------------------------------

SELECT product_name, total_amount, (
    SELECT AVG(total_amount) FROM flourmills_sales
) AS avg_amount FROM flourmills_sales;

-- Úloha 5 --------------------------------------------------------------------

SELECT product_name, total_amount, total_amount / (
    SELECT SUM(total_amount) FROM flourmills_sales
) AS amount_share FROM flourmills_sales

-- Úloha 6 --------------------------------------------------------------------

SELECT * FROM (
    SELECT EXTRACT(MONTH FROM sale_date) AS month, SUM(total_amount) AS monthly_sale FROM flourmills_sales
    GROUP BY month
)
ORDER BY monthly_sale;

-- Úloha 7 --------------------------------------------------------------------

SELECT * FROM (
    SELECT product_category, SUM(total_amount) AS total_sales FROM flourmills_sales
    GROUP BY product_category
)
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

-- Úloha 8 --------------------------------------------------------------------

SELECT product_name, product_category, total_amount FROM flourmills_sales main
WHERE total_amount > (
    SELECT AVG(total_amount) FROM flourmills_sales sub
    WHERE sub.product_category = main.product_category
);

-- Úloha 9 --------------------------------------------------------------------

SELECT product_name, region, total_amount, (
    SELECT MIN(total_amount) AS region_min_amount FROM flourmills_sales sub
    WHERE sub.region = main.region
) FROM flourmills_sales main;

-- Úloha 10 -------------------------------------------------------------------

SELECT product_name FROM flourmills_sales main
WHERE EXISTS(
    SELECT COUNT(DISTINCT EXTRACT(MONTH FROM sale_date)) FROM flourmills_sales sub
    WHERE sub.product_name = main.product_name
);