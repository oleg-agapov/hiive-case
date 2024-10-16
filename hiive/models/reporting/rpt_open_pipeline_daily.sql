
{% set transfer_methods = dbt_utils.get_column_values(table=ref('fct_open_transactions_history'), column='transfer_method')%}

SELECT
    daily_report_date as report_date,

    {% for transfer_method in transfer_methods %}
    COUNT(CASE WHEN transfer_method = '{{ transfer_method }}' THEN transaction_id END) AS open_{{ transfer_method }}_transactions,
    {% endfor %}

    {% for transfer_method in transfer_methods %}
    SUM(CASE WHEN transfer_method = '{{ transfer_method }}' THEN gross_proceeds ELSE 0 END) AS open_{{ transfer_method }}_gross_proceeds,
    {% endfor %}

FROM {{ ref('fct_open_transactions_history') }}
WHERE daily_report_date IS NOT NULL
GROUP BY ALL
