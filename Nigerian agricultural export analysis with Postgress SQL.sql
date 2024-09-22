-- 1. Create Date Columns View

 
CREATE VIEW vw_nigeria_agricultural_export_date_columns AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT * FROM CTE_DateColumns;


-- 2. Top Revenue Product View

 
CREATE VIEW vw_top_revenue_product AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    product_name,
    ROUND(SUM(units_solds * unit_price), -7) AS revenue
FROM CTE_DateColumns
GROUP BY product_name
ORDER BY revenue DESC;


--  3. Top Selling Product View

 
CREATE VIEW vw_top_selling_product AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    product_name,
    SUM(units_solds) AS units_sum
FROM CTE_DateColumns
GROUP BY product_name
ORDER BY units_sum DESC;

-- 4. Most Profitable Product View

 
CREATE VIEW vw_most_profitable_product AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT 
    product_name,
    ROUND(SUM(profit_per_unit * units_solds)/SUM(export_value)*100, 2) AS profit_margin
FROM CTE_DateColumns
GROUP BY product_name
ORDER BY profit_margin DESC;

--  5. Total Revenue per Country View

 
CREATE VIEW vw_total_revenue_per_country AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    export_country,
    ROUND(SUM(export_value)) AS total_revenue
FROM CTE_DateColumns
GROUP BY export_country
ORDER BY total_revenue DESC;

--  6. Product with Highest Revenue Across Export Countries View

 
CREATE VIEW vw_top_product_per_country AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
),
CTE_ProductsRank AS (
    SELECT
        export_country,
        product_name,
        SUM(export_value) AS sum_of_revenue,
        ROW_NUMBER() OVER (PARTITION BY export_country ORDER BY SUM(export_value) DESC) AS row_num
    FROM CTE_DateColumns
    GROUP BY export_country, product_name
)
SELECT *
FROM CTE_ProductsRank
WHERE row_num < 4;

--  7. Yearly Revenue View

 
CREATE VIEW vw_yearly_revenue AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    export_year,
    SUM(export_value) AS sum_of_revenue
FROM CTE_DateColumns
GROUP BY export_year
ORDER BY sum_of_revenue DESC;

--  8. Yearly Percent Change View

 
CREATE VIEW vw_yearly_percent_change AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    export_year,
    SUM(export_value) AS sum_of_revenue,
    LAG(SUM(export_value)) OVER (ORDER BY export_year) AS prev_rev,
    ROUND((SUM(export_value) / LAG(SUM(export_value)) OVER (ORDER BY export_year) -1) * 100, 2) AS percent_change
FROM CTE_DateColumns
GROUP BY export_year
ORDER BY export_year;

--  9. Monthly Revenue View

 
CREATE VIEW vw_monthly_revenue AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    month_no,
    month_name,
    SUM(export_value) AS sum_of_revenue,
    RANK() OVER (ORDER BY SUM(export_value) DESC)
FROM CTE_DateColumns
GROUP BY month_no, month_name
ORDER BY month_no;

--  10. Quarterly Revenue View

 
CREATE VIEW vw_quarterly_revenue AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    DATE_PART('QUARTER', export_date) AS export_quarter,
    SUM(export_value) AS sum_of_revenue
FROM CTE_DateColumns
GROUP BY export_quarter
ORDER BY export_quarter;

--  11. Daily Revenue View

 
CREATE VIEW vw_daily_revenue AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    EXTRACT(DOW FROM export_date) AS day_num,
    TO_CHAR(export_date, 'FMDay') AS day_of_week,
    SUM(export_value) AS sum_of_revenue,
    RANK() OVER (ORDER BY SUM(export_value) DESC)
FROM CTE_DateColumns
GROUP BY day_num, day_of_week
ORDER BY day_num;

--  12. Company with Highest Revenue View

 
CREATE VIEW vw_company_highest_revenue AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT
    company,
    ROUND(SUM(export_value), -7) AS total_revenue
FROM CTE_DateColumns
GROUP BY company
ORDER BY total_revenue DESC;

--  13. Destination Port Revenue Percent Share View

 
CREATE VIEW vw_destination_port_revenue_percent_share AS
WITH CTE_DateColumns AS (
    SELECT *,
        EXTRACT(YEAR FROM export_date) AS export_year,
        EXTRACT(MONTH FROM export_date) AS month_no,
        EXTRACT(DOW FROM export_date) AS day_no,
        TO_CHAR(export_date, 'MONTH') AS month_name,
        TO_CHAR(export_date, 'DAY') AS day_name
    FROM nigeria_agricultural_export
)
SELECT	
    destination_port,
    SUM(export_value) AS revenue,
    ROUND(SUM(export_value) / SUM(SUM(export_value)) OVER () * 100, 2) AS percent_share
FROM CTE_DateColumns
GROUP BY destination_port
ORDER BY percent_share DESC;
Final Notes:
