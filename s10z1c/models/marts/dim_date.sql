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
    (SELECT min(rated_at)::DATE FROM {{ref('stg_ratings')}}),
    (SELECT max(rated_at)::DATE FROM {{ref('stg_ratings')}}),
        INTERVAL '1 day'
) AS gs(d)