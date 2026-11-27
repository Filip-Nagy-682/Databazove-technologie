{{ 
    config(indexes=[
            {'columns': ['user_id']},
            {'columns': ['movie_id']},
            {'columns': ['date_id']},
            {'columns': ['time_id']}
        ]
    ) 
}}

SELECT
    r.rating_id                     AS rating_id,
    r.user_id                       AS user_id,
    r.movie_id                      AS movie_id,
    d.date_id                       AS date_id,
    t.time_id                       AS time_id,
    r.rating                        AS rating,
    1                               AS rating_count,
    ((r.rating - 1)  / 4) * 100     AS rating_percentage
FROM {{ref('stg_ratings')}} r
LEFT JOIN {{ref('dim_date')}} d ON d.rated_at = r.rated_at::DATE
LEFT JOIN {{ref('dim_time')}} t ON t.rated_time = r.rated_at::TIME