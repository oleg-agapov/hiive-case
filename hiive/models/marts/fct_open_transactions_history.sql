WITH

fct_transaction_transitions AS (
    SELECT * FROM {{ ref('fct_transaction_transitions') }}
),

stg_calendar AS (
    SELECT * FROM {{ ref('stg_calendar') }}
),

transition_intervals AS (
    SELECT
        tt.transaction_id,
        tt.new_state AS transaction_state,
        ts.is_open_transaction,
        tt.transfer_method,
        tt.num_shares,
        tt.price_per_share,
        tt.gross_proceeds,
        tt.transitioned_at,
        COALESCE(
                lead(tt.transitioned_at) over(partition BY tt.transaction_id ORDER BY tt.transitioned_at),
                '2099-01-01'
        ) AS next_transitioned_at,
        
    FROM fct_transaction_transitions AS tt
        LEFT JOIN stg_transaction_states ts
            ON ts.transaction_state = tt.new_state
),

daily_transition_intervals AS (
    SELECT
        ti.transaction_id,
        ti.transaction_state,
        ti.transitioned_at,
        ti.next_transitioned_at,
        c.calendar_date AS report_date,
        ti.transfer_method,
        ti.num_shares,
        ti.price_per_share,
        ti.gross_proceeds,
        CASE
            WHEN row_number() over (PARTITION BY ti.transaction_id, C.calendar_date ORDER BY C.calendar_date DESC) = 1
            THEN c.calendar_date
            END
            AS daily_report_date,
        CASE
            WHEN row_number() over (PARTITION BY ti.transaction_id, date_trunc('month', C.calendar_date) ORDER BY C.calendar_date DESC) = 1
            THEN c.calendar_date
            END
            AS monthly_report_date
    FROM transition_intervals AS ti
        CROSS JOIN stg_calendar AS c
    WHERE c.calendar_date:: DATE BETWEEN ti.transitioned_at:: DATE AND ti.next_transitioned_at:: DATE
AND ti.is_open_transaction = TRUE
)


SELECT
    transaction_id,
    transaction_state,
    report_date,
    COALESCE(transfer_method, 'other') as transfer_method,
    num_shares,
    price_per_share,
    gross_proceeds,
    daily_report_date,
    monthly_report_date
FROM daily_transition_intervals
