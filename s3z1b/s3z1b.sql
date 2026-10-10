-- Active: 1790280629501@@127.0.0.1@5432@datacraftinglab_db

-- Úloha 1 --------------------------------------------------------------------

WITH daily_sales AS(
    SELECT sale_date, SUM(total_amount) AS total_daily_sales FROM flourmills_sales
    GROUP BY sale_date
)
SELECT * FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;