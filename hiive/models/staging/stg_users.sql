
with users as (
    SELECT *
    FROM (
        VALUES 
            (1, 'lindsay@hiive.com', NULL),
            (2, 'felicia@hiivemarkets.com', NULL),
            (3, 'matt@buyer.com', 'unaccredited_seller'),
            (4, 'josh@seller.com', 'accredited_seller')
    ) users(id, email, investor_type)
)

select
    id,
    email,
    investor_type
from users
