SELECT
    TRIM(id)::INT AS                user_id,
    TRIM(age)::INT AS               age,
    UPPER(TRIM(gender)) AS          gender,
    TRIM(occupation_id)::INT AS     occupation_id,
    TRIM(ZIP_CODE) AS               zip_code
FROM {{source('bronze', 'users')}}