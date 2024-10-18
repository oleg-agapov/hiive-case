{{
    config(severity='warn')
}}

WITH
    transaction_latest_state AS (
        SELECT
            transaction_id,
            is_open_transaction AS latest_is_open_transaction,
        FROM {{ ref('fct_transaction_transitions') }}
        qualify row_number() over (
            PARTITION BY transaction_id
            ORDER BY transitioned_at DESC) =1
    ),
    
    transaction_was_closed AS (
        SELECT
            transaction_id, is_open_transaction
        FROM {{ ref('fct_transaction_transitions') }}
        WHERE is_open_transaction = FALSE
        GROUP BY ALL
    )

SELECT *
FROM transaction_latest_state AS ts
    LEFT JOIN transaction_was_closed AS tc
        ON tc.transaction_id = ts.transaction_id
WHERE ts.latest_is_open_transaction = TRUE
  AND tc.is_open_transaction = FALSE
