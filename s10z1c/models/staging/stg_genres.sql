SELECT
    TRIM(id)::INT AS    genre_id,
    TRIM(name) AS       genre_name
FROM {{source('bronze', 'genres')}}