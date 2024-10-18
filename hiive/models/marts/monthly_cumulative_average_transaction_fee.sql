{{
    config(enabled=false)
}}

WITH

transactions as (
    SELECT
        id,
        inserted_at_pst,
        fee,
        seller_id
    FROM {{ ref('stg_transactions') }}
),

transaction_transitions AS (
    SELECT
        transaction_id,
        transitioned_at_pst
    FROM {{ ref('stg_transaction_transitions') }}
    WHERE new_state = 'closed_fee_pending'
),

users as (
    SELECT
        id,
        investor_type,
        is_hiive_employee
    FROM {{ ref('stg_users') }}
),


monthly_average_fee AS (
    SELECT
        DATE_TRUNC(
            'month',
            COALESCE(transaction_transitions.transitioned_at_pst, transactions.inserted_at_pst)
        ) AS transaction_month,
        AVG(transactions.fee) AS avg_monthly_fee
    
    FROM transactions
        LEFT JOIN transaction_transitions -- do we want INNER JOIN? if yes, transaction_month can be simplified
            ON transactions.id = transaction_transitions.transaction_id
        LEFT JOIN users
            ON transactions.seller_id = users.id
    WHERE
        users.investor_type = 'unaccredited_seller'
        AND users.is_hiive_employee = FALSE

    GROUP BY transaction_month
),

monthly_avg_fee AS (
    SELECT
        transaction_month,
        AVG(avg_monthly_fee) OVER (
            ORDER BY transaction_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_monthly_average_fee
    FROM monthly_average_fee
)

SELECT
    transaction_month,
    cumulative_monthly_average_fee
FROM monthly_avg_fee
