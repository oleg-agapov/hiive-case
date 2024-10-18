# Task 2: Refactor this query, explain your refactoring choices and how it improves the query

Review the two model files provided below and share details about how you would refactor
them to improve performance, readability, and maintainability.

Questions:
- Share the refactored dbt model(s) you would create (again can be provided in any format, we just want to see written code).
- Feel free to suggest as many changes, improvements, comments, or new/removed models to the project as you see fit. Be prepared to answer questions about the changes you've made (and why you made them).
- What refactoring strategy would you recommend to confirm the output of your model is correct? Be prepared to talk about the pros and cons of whatever strategy you choose.
- How would you audit your refactoring work to confirm the correctness of these new outputs?

# Solution

Original models:
- monthly_cumulative_average_transaction_fee ([source](https://github.com/oleg-agapov/hiive-case/blob/41c098ba52c642d6c154df16ca82bfcfcc386e32/hiive/models/marts/monthly_cumulative_average_transaction_fee.sql))
- dim_hiive_employee_users ([source](https://github.com/oleg-agapov/hiive-case/blob/41c098ba52c642d6c154df16ca82bfcfcc386e32/hiive/models/marts/dim_hiive_employee_users.sql))

My refactoring strategy is:
- make models easier to read
- avoid repeating and potentially repeating parts (DRY)
- incapsulating peices of logic into separate CTEs for better maintainability

Changes made during the [refactoring](https://github.com/oleg-agapov/hiive-case/pull/1):
- added `is_hiive_employee` flag to `stg_users` model (it can be useful in other models as well)
- made `dim_hiive_employee_users` more trivial by referencing `is_hiive_employee` flag
- split `monthly_cumulative_average_transaction_fee` into multiple CTEs
    - there three "import" CTEs: `transactions`, `transaction_transitions` and `users`
    - corresponding calculation and filters were pushed to those import CTEs
    - `monthly_average_fee` now only includes monthly averages, some conditions from the original query were simplified
    - cumulative fee metric now lives in a separate CTE
    - final SELECT now all contains all columns instead of `*`

To ensure that the output of the model is correct:
- compare existing output with the refactored model (# rows and total fees should match)
- if there is a difference, we should be able to explain why (maybe some edge cases were not covered in the original model, or it used wrong assumptions)
- add dbt tests to the model:
    - data tests to ensure overall quality is OK
    - add unit tests with mock data to be sure that the logic is correct
