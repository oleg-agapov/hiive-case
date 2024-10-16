
select
    distinct transaction_state,
    case 
        when transaction_state in ('closed_paid', 'cancelled', 'expired')
            then FALSE
        when transaction_state in ('pending_approval', 'bid_accepted')
            then TRUE
    end as is_open_transaction
from {{ ref('stg_transactions') }}
