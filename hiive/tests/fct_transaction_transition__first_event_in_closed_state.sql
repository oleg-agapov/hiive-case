{{
    config(severity='warn')
}}

SELECT *
FROM (
    SELECT
        transaction_id,
        transitioned_at,
        is_open_transaction,
        new_state,
        row_number() over (partition BY transaction_id ORDER BY transitioned_at) AS rn
    FROM {{ ref('fct_transaction_transitions') }}
)
WHERE rn = 1
  AND is_open_transaction = FALSE
