SELECT
    TRIM(id)::INT AS    age_group_id,
    TRIM(name) AS       age_group_name
FROM {{source('bronze', 'age_group')}}