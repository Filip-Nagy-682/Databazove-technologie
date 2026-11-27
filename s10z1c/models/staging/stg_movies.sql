SELECT
    TRIM(id)::INT AS            movie_id,
    TRIM(title) AS              title,
    TRIM(release_year)::INT AS  release_year
FROM {{source('bronze', 'movies')}}