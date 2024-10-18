{{
    config(enabled=false)
}}

SELECT
    id,
    email
FROM
   {{ ref('stg_users') }}
WHERE
   is_hiive_employee = TRUE
