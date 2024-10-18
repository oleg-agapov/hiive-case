{{
    config(enabled=false)
}}

SELECT
    id,
    email
FROM
   {{ ref('stg_users') }}
WHERE
   email LIKE '%@hiive.com'
   OR email LIKE '%@hiivemarkets.com'
