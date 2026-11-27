SELECT
    DATE_TRUNC('month', d.rated_at) AS rating_month,
    COUNT(*)                        AS rating_count,
    ROUND(AVG(r.rating), 2)         AS avg_rating,
    COUNT(DISTINCT r.user_id)       AS active_users
FROM {{ ref('fact_rating') }} r
JOIN {{ ref('dim_date') }} d ON d.date_id = r.date_id
GROUP BY DATE_TRUNC('month', d.rated_at)