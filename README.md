# Customer Orders Data Cleaning and Exploratory Data Analysis

## Project Overview

This project uses PostgreSQL to clean and analyze a deliberately messy
customer-orders dataset. The workflow moves from raw data staging and
data-quality checks to standardization, type conversion, missing-value
handling, exploratory data analysis (EDA), and sales-performance
analysis.

The supplied CSV, `messy_customer_orders(1).csv`, contains **51,000 rows
and 12 columns**. The SQL work is designed for practice with real-world
data-cleaning problems and analytical SQL techniques.

## Objectives

-   Identify and remove duplicate order records.
-   Standardize inconsistent country, category, status, and return
    values.
-   Clean quantity, price, amount, and date fields.
-   Assess missing values and apply documented replacement rules.
-   Explore order and sales metrics by country, category, product,
    status, and payment method.
-   Analyze trends by year and month.
-   Use CTEs, window functions, ranking, `LAG()`, `LEAD()`, cumulative
    totals, and percentage-of-total calculations.

## Dataset

The dataset has these columns:

  -----------------------------------------------------------------------
  Column                              Description
  ----------------------------------- -----------------------------------
  `order_id`                          Order identifier

  `customer_id`                       Customer identifier

  `order_date`                        Date associated with the order;
                                      initially stored as text

  `country`                           Customer/order country

  `category`                          Product category

  `product`                           Product name

  `quantity`                          Quantity ordered

  `unit_price`                        Unit price, including some currency
                                      symbols

  `total_amount`                      Order amount

  `status`                            Order status

  `payment_method`                    Payment method

  `is_returned`                       Whether the order was returned
  -----------------------------------------------------------------------

The raw dataset intentionally includes data-quality issues such as
missing values, duplicate records, inconsistent capitalization and
labels, negative or zero quantities/amounts, mixed date formats, and
currency symbols in unit prices.

## Tools and Technologies

-   **PostgreSQL** --- data cleaning, transformation, and analysis
-   **pgAdmin 4** or another PostgreSQL client --- running SQL
    statements
-   **CSV** --- source dataset

## Project Workflow

### 1. Load and stage the data

The SQL workflow creates a raw table named `messy_data_dirty` and a
staging copy named `clean_messy_date`. The raw columns are initially
declared as text so that inconsistent source values can be inspected
before type conversion.

Load the CSV into `messy_data_dirty` using your PostgreSQL client.
Confirm that the column order matches the CSV headers.

### 2. Identify and remove duplicates

`ROW_NUMBER()` is used with all order fields in the partition to
identify repeated, identical records. The duplicate rows are assigned
`row_num > 1` and removed from the working table.

This method removes fully identical rows; it does not automatically
decide whether two records with the same order ID but different details
are duplicates.

### 3. Standardize text fields

The SQL uses `TRIM()` and `INITCAP()` to remove surrounding spaces and
normalize capitalization. `CASE` expressions map known variants to
common labels, including:

-   Country abbreviations such as `UK` and `U.K.` to `United Kingdom`
-   Country variants such as `USA`, `U.S.A`, and `US` to `United States`
-   `Home And Garden` to `Home & Garden`
-   Common true/false variants in `is_returned` to `YES` or `NO`

The mappings are based on the variants explicitly handled in the SQL
script. Review distinct values after cleaning to find any remaining
variants.

### 4. Clean numeric fields

-   Negative quantities are changed to their absolute values.
-   Zero quantities are converted to `NULL`.
-   Negative `total_amount` values are changed to their absolute values.
-   Zero `total_amount` values are converted to `NULL`.
-   `quantity` is converted to an integer and `total_amount` to a
    numeric type.
-   Currency symbols and commas are removed from `unit_price` to create
    a numeric `amount_payment` column.
-   A `Currency` column is added to label prices containing `$`, `£`, or
    `€` as USD, GBP, or EUR.

**Currency caution:** Removing currency symbols does not convert values
into a common currency. Do not add or compare `amount_payment` values
across USD, GBP, and EUR as if they were the same currency unless you
first apply a documented exchange-rate conversion. Also validate that
each `unit_price` value is numeric after symbol removal before casting
it.

### 5. Parse dates

A helper function, `safe_to_date()`, attempts to parse multiple date
formats and returns `NULL` when parsing fails. The workflow then
converts `order_date` to the PostgreSQL `date` type.

Inspect any remaining `NULL` dates and validate ambiguous formats
carefully. Date strings such as `03/04/2023` can mean different dates
depending on the source convention, so parsing rules should match the
dataset's intended format.

### 6. Handle missing values

The script checks missing values across columns and removes rows where
`customer_id` is `NULL`. It also uses `COALESCE()` to replace missing
values, including:

-   `quantity` with `5`
-   `total_amount` with `1811.4`
-   `country` and `category` with `Unknown`

The numeric replacement values are the values specified in the SQL
workflow. Verify that they are appropriate for the dataset before using
the cleaned data for business decisions. The script should also be
reviewed for empty strings, which are not the same as SQL `NULL`.

### 7. Exploratory data analysis

The analysis queries calculate summary statistics such as:

-   Minimum and maximum order dates and the date span
-   Total, average, minimum, and maximum quantity
-   Total, average, minimum, and maximum order amount
-   Counts of non-null values
-   Sales and quantity summaries grouped by country, category, product,
    order status, and payment method

### 8. Sales trends and advanced analysis

The later queries demonstrate:

-   Yearly and monthly sales trends
-   Sales and order/customer counts by country and year
-   Cumulative totals using `SUM() OVER (...)`
-   Top-five country and category rankings by year using `DENSE_RANK()`
-   Previous- and next-period comparisons using `LAG()` and `LEAD()`
-   Percentage-of-total calculations:
    -   each country-year's share of all sales,
    -   each year's share of a country's sales,
    -   each country's share of a year's sales.

CTEs (`WITH`) separate aggregation steps from later calculations, while
window functions preserve each result row and calculate comparisons
across rows.

## Running the Project

1.  Install PostgreSQL and open pgAdmin 4 or another SQL client.
2.  Create or select a database for the project.
3.  Import `messy_customer_orders(1).csv` into `messy_data_dirty`,
    preserving the column names and order.
4.  Run the SQL statements in sequence, starting with table creation and
    staging.
5.  Review each cleaning step and inspect distinct values, null counts,
    and data types before applying updates.
6.  Run the EDA and analysis queries after the cleaning workflow has
    completed.
7.  Export query results if you want to use them in a report or
    visualization tool.

**Important:** The SQL file is a working analysis script and should be
reviewed before running from top to bottom on important data. Some
statements depend on earlier schema changes, and rerunning
`CREATE TABLE`, `ALTER TABLE`, or `UPDATE` statements may require
resetting the database or adapting the script. Back up the raw table
before destructive operations.

## Suggested Project Structure

``` text
customer-orders-data-cleaning/
├── README.md
├── messy_customer_orders(1).csv
└── sql/
    └── data_cleaning_and_analysis.sql
```

The SQL filename above is a suggested name; save your SQL statements in
that file if you want to organize the project this way.

## Key SQL Concepts Practiced

`CREATE TABLE`, `INSERT INTO`, `UPDATE`, `DELETE`, `ALTER TABLE`,
`CASE`, `COALESCE`, `TRIM`, `INITCAP`, `ROW_NUMBER`, aggregate
functions, `GROUP BY`, CTEs, `DENSE_RANK`, `LAG`, `LEAD`, and window
functions using `OVER()` and `PARTITION BY`.

## Limitations and Further Improvements

-   Validate all date formats and parsing results before converting the
    complete column.
-   Check numeric strings before casting to prevent conversion errors.
-   Review the business meaning of negative and zero quantities or
    amounts before replacing them.
-   Document the rationale for imputation values and compare results
    before and after imputation.
-   Resolve blank strings as well as `NULL` values.
-   Avoid aggregating amounts in different currencies without
    conversion.
-   Consider preserving an untouched raw table and creating a separate
    final clean table.
-   Add validation queries or constraints for required identifiers,
    valid dates, positive quantities, and acceptable status values.

## Project Outcome

The project demonstrates an end-to-end SQL workflow for cleaning a messy
customer-orders dataset and performing exploratory and advanced sales
analysis in PostgreSQL. It provides practice in preparing data for
reporting and in deriving country-, category-, product-, and time-based
business insights.
