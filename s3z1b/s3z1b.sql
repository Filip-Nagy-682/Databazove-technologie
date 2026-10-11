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

-- Úloha 4 --------------------------------------------------------------------

WITH customer_revenue AS(
    SELECT customer_type, SUM(total_amount) AS revenue FROM flourmills_sales
    GROUP BY customer_type
),
total_customer_revenue AS(
    SELECT *, SUM(revenue) OVER() AS total_revenue,  ROUND(revenue /SUM(revenue) OVER() * 100, 2) AS revenue_percentage from customer_revenue
)
SELECT * FROM total_customer_revenue
ORDER BY revenue DESC;

-- Úloha 5 --------------------------------------------------------------------

WITH customer_orders AS(
    SELECT customer_id, product_name, sale_date, total_amount, ROW_NUMBER() OVER(
        PARTITION BY customer_id
        ORDER BY sale_date DESC
    ) FROM flourmills_sales
)
SELECT customer_id, product_name, sale_date, total_amount FROM customer_orders o
WHERE row_number = (
    SELECT MIN(row_number) FROM customer_orders i
    WHERE i.customer_id = o.customer_id
);

-- Úloha 6 --------------------------------------------------------------------

WITH RECURSIVE bounds AS(
    SELECT MIN(sale_date) AS minimum, MAX(sale_date) AS maximum FROM flourmills_sales
),
dates AS(
    SELECT minimum AS day FROM bounds
    UNION ALL
    SELECT day + 1 FROM dates
    WHERE day < (SELECT maximum FROM bounds)
)
SELECT * FROM dates;

-- Úloha 7 --------------------------------------------------------------------

WITH RECURSIVE monthly_revenue AS(
    SELECT DATE_TRUNC('month', sale_date) as month, SUM(total_amount) AS revenue FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS(
    SELECT ROW_NUMBER() OVER(
        ORDER BY month
    ) AS rn, month, revenue FROM monthly_revenue
),
cumulative_target AS(
    SELECT rn, month, revenue, revenue AS cumulative_revenue FROM ordered_months
    WHERE rn = 1
    UNION ALL
    SELECT rn + 1, month, revenue, cumulative_revenue + (SELECT revenue FROM ordered_months WHERE rn = rn + 1)
    FROM cumulative_target
    WHERE cumulative_revenue < 500000000
)
SELECT DISTINCT * FROM cumulative_target
ORDER BY rn;