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
                case when ts.is_open_transaction = FALSE then tt.transitioned_at end,
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
        ti.is_open_transaction,
        ti.transitioned_at,
        ti.next_transitioned_at,
        c.calendar_date AS report_date,
        ti.transfer_method,
        ti.num_shares,
        ti.price_per_share,
        ti.gross_proceeds,
    FROM transition_intervals AS ti
        CROSS JOIN stg_calendar AS c
    WHERE c.calendar_date:: DATE BETWEEN ti.transitioned_at:: DATE AND ti.next_transitioned_at:: DATE
    -- AND ti.is_open_transaction = TRUE
    qualify row_number() over (
        PARTITION BY ti.transaction_id, c.calendar_date 
        ORDER BY ti.transitioned_at DESC
    ) = 1
)


SELECT
    transaction_id,
    transaction_state,
    is_open_transaction,
    transitioned_at,
    next_transitioned_at,
    report_date,
    COALESCE(transfer_method, 'other') as transfer_method,
    num_shares,
    price_per_share,
    gross_proceeds,
    case when row_number() over (
        PARTITION BY transaction_id, date_trunc('month', report_date)
        ORDER BY report_date DESC) = 1
        then date_trunc('month', report_date)
        else null
    end as monthly_report_date
FROM daily_transition_intervals
