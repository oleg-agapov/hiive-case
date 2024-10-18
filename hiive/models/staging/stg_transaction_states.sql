
select
    distinct new_state as transaction_state,
    case 
        when new_state in ('closed_paid', 'cancelled', 'expired', 'approval_declined')
            then FALSE
        when new_state in ('pending_approval', 'bid_accepted')
            then TRUE
    end as is_open_transaction
from {{ ref('stg_transaction_transitions') }}
