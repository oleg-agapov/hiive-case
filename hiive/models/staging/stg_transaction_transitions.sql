
select
    id as transition_id,
    transaction_id,
    strptime(transitioned_at, '%Y-%m-%d %H:%M:%S.%f Z') as transitioned_at,
    new_state,
    strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f Z') as inserted_at,
    strptime(updated_at, '%Y-%m-%d %H:%M:%S.%f Z') as updated_at,
    _fivetran_deleted,
    strptime(_fivetran_synced, '%Y-%m-%d %H:%M:%S.%f Z') as _fivetran_synced
from {{ ref('seed_transaction_transitions') }}
