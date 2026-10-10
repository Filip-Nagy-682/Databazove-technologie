-- Active: 1790280629501@@127.0.0.1@5432@datacraftinglab_db

-- Úloha 1 --------------------------------------------------------------------

WITH daily_sales AS(
    SELECT sale_date, SUM(total_amount) AS total_daily_sales FROM flourmills_sales
    GROUP BY sale_date
)
SELECT * FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

-- Úloha 2 --------------------------------------------------------------------

WITH category_sales AS(
    SELECT product_category, SUM(total_amount) AS total_category_sales FROM flourmills_sales
    GROUP BY product_category
)
SELECT * FROM category_sales
ORDER BY total_category_sales DESC;

-- Úloha 3 --------------------------------------------------------------------

WITH category_sales AS(
    SELECT product_category, SUM(total_amount) AS total_product_sales FROM flourmills_sales
    GROUP BY (product_category, product_name)
),
rank_cte AS(
        SELECT *, RANK() OVER(
        PARTITION BY product_category
        ORDER BY total_product_sales DESC
    ) AS category_rank FROM category_sales
)
SELECT * FROM rank_cte
WHERE category_rank = 1 OR category_rank = 3
ORDER BY (product_category, category_rank);