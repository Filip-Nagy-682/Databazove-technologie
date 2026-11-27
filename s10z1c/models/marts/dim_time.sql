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
FROM GENERATE_SERIES(0, 86399) AS gs(sec)