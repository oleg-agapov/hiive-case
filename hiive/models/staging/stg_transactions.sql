
select
    id as transaction_id,
    bid_id,
    state as transaction_state,
    transfer_method,
    strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f Z') as inserted_at,
    company_id,
    num_shares,
    price_per_share,
    gross_proceeds,
    _fivetran_deleted,
    strptime(_fivetran_synced, '%Y-%m-%d %H:%M:%S.%f Z') as _fivetran_synced
from {{ ref('seed_transactions') }}
