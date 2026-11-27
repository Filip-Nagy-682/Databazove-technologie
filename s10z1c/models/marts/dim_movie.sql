SELECT
    m.movie_id                          AS movie_id,
    m.title                             AS title,
    m.release_year                      AS release_year,
    COALESCE(g.genre_name, 'unknown')   AS genre_name
FROM {{ref('stg_movies')}} m
LEFT JOIN (
    SELECT gm.movie_id, STRING_AGG(
        g.genre_name, ', '
         ORDER BY g.genre_name
    ) AS genre_name
    FROM {{ref('stg_genres_movies')}} gm
    join {{ref('stg_genres')}} g ON g.genre_id = gm.genre_id
    GROUP BY gm.movie_id
) g ON g.movie_id = m.movie_id
ORDER BY m.movie_id