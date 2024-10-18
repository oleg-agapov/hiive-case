# Task 3: Complete a review of your peer's code

Review the dbt model code below and provide suggestions you would make as part of a peer code review.

Questions:
- In any format, include specific details about things you would give feedback on and why.
- Be prepared to answer questions about your feedback.

# Solution

Added my comments to the [Pull Request](https://github.com/oleg-agapov/hiive-case/pull/2).

Here is my review:
- Since this model contains calculations and aggregations, it cannot be a staging model. It's better to convert it to a data mart and put to `/marts` folder
- There is no consistency in aliasing: some CTEs have no table aliases, some have shortened table name, some have full table names. It's better to use a unified approach described in out team's conventions document.
- `raw_customers` uses table name instead of `ref()`
- also, `raw_customers` uses `orders` table instead of `users`
- `raw_orders` CTE uses source() instead of ref()
- one transformation can be pushed up to the source CTE
- there is a use of `ORDER BY` clause, which is generally not necessary in dbt, and should be used only if justified
