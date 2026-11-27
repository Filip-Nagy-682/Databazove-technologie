SELECT
    m.title AS                  movie_title,
    ROUND(AVG(r.rating), 2) AS  average_rating,
    COUNT(*) AS                 rating_count
FROM {{ ref('fact_rating') }} r
JOIN {{ ref('dim_movie') }} m ON m.movie_id = r.movie_id
GROUP BY r.movie_id, m.title
ORDER BY ROUND(AVG(r.rating), 2) DESC