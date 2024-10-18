{{
    config(enabled=false)
}}

WITH

monthly_avg_fee AS (
    SELECT
        transaction_date,
        AVG(monthly_fee) OVER (
            ORDER BY transaction_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_average_fee
    FROM (
        SELECT
            DATE_TRUNC(
                'month',
                COALESCE(transaction_transitions.transitioned_at_pst, transactions.inserted_at_pst)
            ) AS transaction_date,
            AVG(fee) AS monthly_fee
          FROM {{ ref('stg_transactions') }} AS transactions
            LEFT JOIN {{ ref('stg_transaction_transitions') }} AS transaction_transitions
                ON transactions.id = transaction_transitions.transaction_id
                AND transaction_transitions.new_state = 'closed_fee_pending'
            LEFT JOIN {{ ref('stg_users') }} AS users
                ON transactions.seller_id = users.id
        WHERE
            transaction_transitions.new_state = 'closed_fee_pending'
            AND users.investor_type = 'unaccredited_seller'
            AND seller_id NOT IN (
                SELECT id 
                FROM {{ref('dim_hiive_employee_users')}}
            )
        GROUP BY transaction_date
    ) AS monthly_fee_data
)


SELECT 
*
FROM monthly_avg_fee
