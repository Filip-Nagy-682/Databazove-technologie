-- Active: 1790280629501@@127.0.0.1@5432@movielens_elt

\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS gold;

--DIM_USER
CREATE TABLE gold.dim_user(
    user_id     INT NOT NULL UNIQUE,
    gender      CHAR(1) NOT NULL CHECK(gender IN ('M', 'F')),
    zip_code    VARCHAR(10) NOT NULL,
    age_group   VARCHAR(20) NOT NULL,
    occupation  VARCHAR(50) NOT NULL
);

--DIM_MOVIE
CREATE TABLE gold.dim_movie(
    movie_id        INT NOT NULL UNIQUE,
    title           VARCHAR(200) NOT NULL,
    release_year    INT NOT NULL,
    genre_name      VARCHAR(200) NOT NULL    -- < Všetky žánre v jednom riadku
);

--DIM_DATE
CREATE TABLE gold.dim_date(
    date_id     INT PRIMARY KEY,
    rated_at    DATE NOT NULL UNIQUE,
    day         INT NOT NULL,
    month       INT NOT NULL,
    year        INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name    VARCHAR(10) NOT NULL,
    week        INT NOT NULL,
    month_name  VARCHAR(10) NOT NULL,
    quarter     INT NOT NULL
);

--DIM_TIME
CREATE TABLE gold.dim_time(
    time_id     INT PRIMARY KEY,
    rated_time  TIME NOT NULL UNIQUE,
    hour        INT NOT NULL,
    minute      INT NOT NULL,
    second      INT NOT NULL,
    time_of_day VARCHAR(10) NOT NULL
);

--FACT_RATING
CREATE TABLE gold.fact_rating(
    rating_id           INT PRIMARY KEY,
    user_id             INT NOT NULL REFERENCES gold.dim_user (user_id),
    movie_id            INT NOT NULL REFERENCES gold.dim_movie (movie_id),
    date_id             INT NOT NULL REFERENCES gold.dim_date (date_id),
    time_id             INT NOT NULL REFERENCES gold.dim_time (time_id),
    rating              NUMERIC(2, 1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    rating_count        INT NOT NULL,
    rating_percentage   INT NOT NULL
);

--Indexy na cudzie kľúče pretože Postgre ich nevitvára automaticky

CREATE INDEX ON gold.fact_rating (user_id);
CREATE INDEX ON gold.fact_rating (movie_id);
CREATE INDEX ON gold.fact_rating (date_id);
CREATE INDEX ON gold.fact_rating (time_id);

BEGIN;

TRUNCATE gold.fact_rating,
gold.dim_user,
gold.dim_movie,
gold.dim_date,
gold.dim_time;  -- RESTART IDENTITY ak potrebujeme resetovať autoincrement

INSERT INTO gold.dim_user
    SELECT
        u.user_id                               AS user_id,
        u.gender                                AS gender,
        u.zip_code                              AS zip_code,
        COALESCE(a.age_group_name, 'unknown')   AS age_group,
        COALESCE(o.occupation_name, 'unknown')  AS occupation
    FROM silver.stg_users u
    LEFT JOIN silver.stg_age_group a ON a.age_group_id = u.age
    LEFT JOIN silver.stg_occupations o ON o.occupation_id = u.occupation_id
    ORDER BY u.user_id;

--Coalesce nahradí NULL s hodnotou

--DIM_MOVIE
INSERT INTO gold.dim_movie
    SELECT
        m.movie_id                          AS movie_id,
        m.title                             AS title,
        m.release_year                      AS release_year,
        COALESCE(g.genre_name, 'unknown')   AS genre_name
    FROM silver.stg_movies m
    LEFT JOIN (
        SELECT gm.movie_id, STRING_AGG(
            g.genre_name, ', '
            ORDER BY g.genre_name
        ) AS genre_name
        FROM silver.stg_genres_movies gm
        join silver.stg_genres g ON g.genre_id = gm.genre_id
        GROUP BY gm.movie_id
    ) g ON g.movie_id = m.movie_id
    ORDER BY m.movie_id;


--DIM_DATE
INSERT INTO gold.dim_date
    SELECT
        TO_CHAR(d, 'YYYMMDD')::INT      AS date_id,
        d                               AS rated_at,
        EXTRACT(day FROM d)::INT        AS day,
        EXTRACT(month FROM d)::INT      AS month,
        EXTRACT(year FROM d)::INT       AS year,
        EXTRACT(isodow FROM d)::INT     AS day_of_week,
        TRIM(TO_CHAR(d, 'Day'))         AS day_name,
        EXTRACT(week FROM d)::INT       AS week,
        TRIM(TO_CHAR(d, 'Month'))       AS month_name,
        EXTRACT(quarter FROM d)::INT    AS quarter
    FROM GENERATE_SERIES(
        (SELECT min(rated_at)::DATE FROM silver.stg_ratings),
        (SELECT max(rated_at)::DATE FROM silver.stg_ratings),
        INTERVAL '1 day'
    ) AS gs(d);


--DIM_TIME
INSERT INTO gold.dim_time
    SELECT
        TO_CHAR(MAKE_INTERVAL(secs => sec), 'HH24MISS')::INT    AS time_id,
        MAKE_TIME(sec / 3600, (sec / 60) % 60, sec % 60)        AS rated_time,
        sec / 3600                                              AS hour,
        (sec / 60) % 60                                         AS minute,
        sec % 60                                                AS second,
        CASE
            WHEN sec / 3600 BETWEEN 5 AND 11    THEN 'morning'
            WHEN sec / 3600 BETWEEN 12 AND 17   THEN 'afternoon'
            WHEN sec / 3600 BETWEEN 8 AND 21    THEN 'evening'
            ELSE                                'night'
        END AS time_of_day
    FROM GENERATE_SERIES(0, 86399) AS gs(sec);


INSERT INTO gold.fact_rating
    SELECT
        r.rating_id                     AS rating,
        r.user_id                       AS user_id,
        r.movie_id                      AS movie_id,
        d.date_id                       AS date_id,
        t.time_id                       AS time_id,
        r.rating                        AS rating,
        1                               AS rating_count,
        ((r.rating - 1)  / 4) * 100     AS rating_percentage
    FROM silver.stg_ratings r
    LEFT JOIN gold.dim_date d ON d.rated_at = r.rated_at::DATE
    LEFT JOIN gold.dim_time t ON t.rated_time = r.rated_at::TIME;

COMMIT;