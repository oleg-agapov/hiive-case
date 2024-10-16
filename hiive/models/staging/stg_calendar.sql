with 

date_spine AS (
    {{ date_spine("DAY", "'2024-07-01'::DATE", "CURRENT_DATE") }}
)


select date_day as calendar_date
from date_spine
