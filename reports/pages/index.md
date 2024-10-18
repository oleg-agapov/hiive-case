---
title: Hiive financial dashboard
---

This is a sample dashboard that shows the financial data for Hiive platform.

## Current stats

```sql monthly_totals
  with monthly_data as (
    SELECT
      monthly_report_date as report_month,
      COUNT(CASE WHEN is_open_transaction THEN transaction_id END) AS open_transactions,
      COUNT(CASE WHEN NOT is_open_transaction THEN transaction_id END) AS closed_transactions,
      SUM(CASE WHEN is_open_transaction THEN gross_proceeds ELSE 0 END) AS open_gross_proceeds,
      SUM(CASE WHEN NOT is_open_transaction THEN gross_proceeds ELSE 0 END) AS closed_gross_proceeds,
    FROM hiive.fct_transaction_history
    WHERE monthly_report_date IS NOT NULL
    GROUP BY ALL
  )

  select
    report_month,
    open_transactions,
    closed_transactions,
    open_gross_proceeds,
    closed_gross_proceeds,
    coalesce(open_transactions / lag(open_transactions) OVER (ORDER BY report_month) - 1, 0) AS open_transactions_diff,
    coalesce(closed_transactions / lag(closed_transactions) OVER (ORDER BY report_month) - 1, 0) AS closed_transactions_diff,
    coalesce(open_gross_proceeds / lag(open_gross_proceeds) OVER (ORDER BY report_month) - 1, 0) AS open_gross_proceeds_diff,
    coalesce(closed_gross_proceeds / lag(closed_gross_proceeds) OVER (ORDER BY report_month) - 1, 0) AS closed_gross_proceeds_diff,
  from monthly_data
  order by report_month desc
```

<Grid cols=4>
<BigValue 
  data={monthly_totals} 
  value=open_transactions
  sparkline=report_month
  comparison=open_transactions_diff
  comparisonFmt=pct1
  comparisonTitle="vs. Last Month"
/>
<BigValue 
  data={monthly_totals} 
  value=closed_transactions
  sparkline=report_month
  comparison=closed_transactions_diff
  comparisonFmt=pct1
  comparisonTitle="vs. Last Month"
/>
<BigValue 
  data={monthly_totals} 
  value=open_gross_proceeds
  fmt=usd1M
  sparkline=report_month
  comparison=open_gross_proceeds_diff
  comparisonFmt=pct1
  comparisonTitle="vs. Last Month"
/>
<BigValue 
  data={monthly_totals} 
  value=closed_gross_proceeds
  fmt=usd1M
  sparkline=report_month
  comparison=closed_gross_proceeds_diff
  comparisonFmt=pct1
  comparisonTitle="vs. Last Month"
/>
</Grid>

## Monthly stats

These charts show the monthly stats for transactions on the Hiive platform.

Dat ais split per transaction status (open/closed) and transfer method.

```sql monthly_stats_per_state
  SELECT
    monthly_report_date as report_month,
    case when is_open_transaction then 'Open' else 'Closed' end as transaction_state,
    COUNT(transaction_id) AS transactions,
    SUM(gross_proceeds) AS gross_proceeds,
  FROM hiive.fct_transaction_history
  WHERE monthly_report_date IS NOT NULL
  and transfer_method in ('direct', 'forward_contract')
  GROUP BY ALL
```

<Grid cols=2>
  <BarChart
      data={monthly_stats_per_state}
      title="Transactions"
      x="report_month"
      xFmt="mmm yyyy"
      y="transactions"
      series="transaction_state"
  />
  <BarChart
      data={monthly_stats_per_state}
      title="Gross proceeds"
      x="report_month"
      xFmt="mmm yyyy"
      y="gross_proceeds"
      yFmt="usd"
      series="transaction_state"
  />
</Grid>


```sql monthly_stats_per_transfer_method
  SELECT
    monthly_report_date as report_month,
    transfer_method,
    COUNT(CASE WHEN is_open_transaction THEN transaction_id END) AS open_transactions,
    COUNT(CASE WHEN NOT is_open_transaction THEN transaction_id END) AS closed_transactions,
    SUM(CASE WHEN is_open_transaction THEN gross_proceeds ELSE 0 END) AS open_gross_proceeds,
    SUM(CASE WHEN NOT is_open_transaction THEN gross_proceeds ELSE 0 END) AS closed_gross_proceeds,
  FROM hiive.fct_transaction_history
  WHERE monthly_report_date IS NOT NULL
  and transfer_method in ('direct', 'forward_contract')
  GROUP BY ALL
```

<Grid cols=2>
  <BarChart
      data={monthly_stats_per_transfer_method}
      title="Open transactions"
      x="report_month"
      xFmt="mmm yyyy"
      y="open_transactions"
      series="transfer_method"
  />
  <BarChart
      data={monthly_stats_per_transfer_method}
      title="Open gross proceeds"
      x="report_month"
      xFmt="mmm yyyy"
      y="open_gross_proceeds"
      yFmt="usd"
      series="transfer_method"
  />
</Grid>


## Historical data

Use filters to find a specific information about transactions on any historical day.

```sql open_statuses
  SELECT 'Open' as status
  UNION
  SELECT 'Closed' as status
```

```sql transaction_states
  SELECT
    distinct transaction_state
  FROM hiive.fct_transaction_history
  WHERE transfer_method in ('direct', 'forward_contract')
```

```sql transfer_methods
  SELECT
    distinct transfer_method
  FROM hiive.fct_transaction_history
  WHERE transfer_method in ('direct', 'forward_contract')
```

<Dropdown
  data={open_statuses}
  name=status
  value=status
  --multiple=true
  --selectAllByDefault=true
  --title="Transaction status"
  >
  <DropdownOption value="%" valueLabel="All statuses"/>
</Dropdown>

<Dropdown
  data={transaction_states}
  name=transaction_state
  value=transaction_state
  --multiple=true
  --selectAllByDefault=true
  --title="Transaction state"
  >
  <DropdownOption value="%" valueLabel="All states"/>
</Dropdown>

<Dropdown
  data={transfer_methods}
  name=transfer_method
  value=transfer_method
  >
  <DropdownOption value="%" valueLabel="All transfer methods"/>
</Dropdown>

```sql historical_data
  SELECT
    report_date,
    COUNT(transaction_id) AS transactions,
    SUM(gross_proceeds) AS gross_proceeds
  FROM hiive.fct_transaction_history
  WHERE CASE WHEN is_open_transaction THEN 'Open' ELSE 'Closed' END LIKE '${inputs.status.value}'
    AND transaction_state LIKE '${inputs.transaction_state.value}'
    AND transfer_method LIKE '${inputs.transfer_method.value}'
  GROUP BY ALL
  ORDER BY report_date
```

<LineChart
    data={historical_data}
    title="Historical transactions and gross proceeds"
    x=report_date
    y=transactions
    y2=gross_proceeds
    y2Fmt=usd1M
/>
