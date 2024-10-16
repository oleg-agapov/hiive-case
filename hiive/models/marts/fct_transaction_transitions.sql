
with

stg_transaction_transitions as (
    select * from {{ ref('stg_transaction_transitions') }}
),

stg_transactions as (
    select * from {{ ref('stg_transactions') }}
),

stg_transaction_states as (
    select * from {{ ref('stg_transaction_states') }}
)

select
    tt.transition_id,
    tt.transaction_id,
    tt.transitioned_at,
    tt.new_state,
    ts.is_open_transaction,
    t.num_shares,
    t.transfer_method,
    t.company_id,
    t.num_shares,
    t.price_per_share,
    t.gross_proceeds,
    tt.inserted_at,
    tt.updated_at,
    tt._fivetran_deleted,
    tt._fivetran_synced,
from stg_transaction_transitions as tt
left join stg_transaction_states as ts
    on ts.transaction_state = tt.new_state
left join stg_transactions as t
    on t.transaction_id = tt.transaction_id
