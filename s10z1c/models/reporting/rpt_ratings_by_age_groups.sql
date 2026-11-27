SELECT
    u.age_group AS              age_group,
    ROUND(AVG(r.rating), 2) AS  average_rating
FROM {{ ref('fact_rating') }} r
JOIN {{ ref('dim_user') }} u ON u.user_id = r.user_id
GROUP BY u.age_group