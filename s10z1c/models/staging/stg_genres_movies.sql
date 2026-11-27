SELECT
    TRIM(id)::INT AS        genre_movie_id,
    TRIM(movie_id)::INT AS  movie_id,
    TRIM(genre_id)::INT AS  genre_id
FROM {{source('bronze', 'genres_movies')}}