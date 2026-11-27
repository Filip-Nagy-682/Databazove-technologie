SELECT
    TRIM(id)::INT AS                rating_id,
    TRIM(user_id)::INT AS           user_id,
    TRIM(movie_id)::INT AS          movie_id,
    TRIM(rating)::NUMERIC(2, 1) AS  rating,
    TRIM(rated_at)::TIMESTAMP AS    rated_at
FROM {{source('bronze', 'ratings')}}