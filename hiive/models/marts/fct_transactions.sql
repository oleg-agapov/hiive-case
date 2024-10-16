
with

stg_transactions as (
    select * from {{ ref('stg_transactions') }}
),

stg_transaction_states as (
    select * from {{ ref('stg_transaction_states') }}
),

stg_transaction_transitions as (
    select * from {{ ref('stg_transaction_transitions') }}
),

transaction_last_updated_at as (
    select
        transaction_id,
        max(transitioned_at) as last_updated_at
    from stg_transaction_transitions
    group by 1
)


select
    t.transaction_id,
    t.bid_id,
    t.transaction_state,
    ts.is_open_transaction,
    t.transfer_method,
    t.inserted_at,
    lu.last_updated_at,
    t.company_id,
    t.num_shares,
    t.price_per_share,
    t.gross_proceeds,
    t._fivetran_deleted,
    t._fivetran_synced
from stg_transactions as t
left join stg_transaction_states as ts
    on ts.transaction_state = t.transaction_state
left join transaction_last_updated_at as lu
    on lu.transaction_id = t.transaction_id
