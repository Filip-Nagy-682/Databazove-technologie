SELECT
    TRIM(id)::INT AS    occupation_id,
    TRIM(name) AS       occupation_name
FROM {{source('bronze', 'occupations')}}