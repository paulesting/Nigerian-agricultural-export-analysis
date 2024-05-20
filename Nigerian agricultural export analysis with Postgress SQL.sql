--DATA WRANGLING
--create necessary date columns

ALTER TABLE nigeria_agricultural_export
ADD COLUMN export_year SMALLINT;

ALTER TABLE nigeria_agricultural_export
ADD COLUMN month_name TEXT;

ALTER TABLE nigeria_agricultural_export
ADD COLUMN month_no SMALLINT;

ALTER TABLE nigeria_agricultural_export
ADD COLUMN day_name TEXT;

ALTER TABLE nigeria_agricultural_export
ADD COLUMN day_no SMALLINT;

UPDATE nigeria_agricultural_export
SET export_year = EXTRACT(YEAR FROM export_date);

UPDATE nigeria_agricultural_export
SET month_no = EXTRACT(MONTH FROM export_date);

UPDATE nigeria_agricultural_export
SET day_no = EXTRACT(DOW FROM export_date);

UPDATE nigeria_agricultural_export
SET month_name = TO_CHAR(export_date, 'MONTH');

UPDATE nigeria_agricultural_export
SET day_name = TO_CHAR(export_date, 'DAY');

SELECT *
FROM nigeria_agricultural_export


---sales performance
--Top revenue product
SELECT
	product_name,
	ROUND(SUM(units_solds * unit_price), -7) AS revenue
FROM nigeria_agricultural_export
GROUP BY product_name
ORDER BY revenue DESC

--Top selling product
SELECT
	product_name,
	SUM(units_solds) AS units_sum
FROM nigeria_agricultural_export
GROUP BY product_name
ORDER BY units_sum DESC

--Most profitable product
SELECT 
	product_name,
	ROUND(SUM(profit_per_unit * units_solds)/SUM(export_value)*100, 2) profit_margin
FROM nigeria_agricultural_export
GROUP BY product_name
ORDER BY profit_margin DESC

--product cost and profit comparison
SELECT
	product_name,
	ROUND(SUM((unit_price - profit_per_unit) * units_solds) / SUM(export_value) *100,2) AS COGS,
	ROUND(SUM(profit_per_unit * units_solds)/SUM(export_value)*100, 2) profit_margin
FROM nigeria_agricultural_export
GROUP BY product_name
ORDER BY profit_margin DESC


---sales variation across country

--Total revenue per country
SELECT
	export_country,
	ROUND(SUM(export_value)) AS total_revenue
FROM nigeria_agricultural_export
GROUP BY export_country
ORDER BY total_revenue DESC

--Avg revenue per country
SELECT
	export_country,
	ROUND(AVG(export_value)) AS total_revenue
FROM nigeria_agricultural_export
GROUP BY export_country
ORDER BY total_revenue DESC

--product with highest revenue across export countries
SELECT * 
FROM
	(SELECT	
		export_country,
		product_name,
		SUM(export_value) sum_of_revenue,
		ROW_NUMBER() OVER(PARTITION BY export_country ORDER BY SUM(export_value) DESC) AS row_num
	FROM nigeria_agricultural_export
	GROUP BY export_country, product_name) AS products_rank
WHERE row_num < 4


---Time series analysis
--yearly revenue
SELECT
	export_year,
	SUM(export_value) sum_of_revenue
FROM nigeria_agricultural_export
GROUP BY export_year
ORDER BY sum_of_revenue DESC

--yearly percent change
SELECT
	export_year,
	SUM(export_value) sum_of_revenue,
	LAG(SUM(export_value)) OVER() AS prev_rev,
	(
		ROUND((SUM(export_value) / 
		 LAG(SUM(export_value)) 
		 	OVER(ORDER BY export_year) -1) * 100, 2) 
	) AS percent_change
FROM nigeria_agricultural_export
GROUP BY export_year
ORDER BY export_year

--monthly revenue
SELECT
	month_no
	month_name,
	SUM(export_value) AS sum_of_revenue,
	RANK() OVER(ORDER BY SUM(export_value) DESC)
FROM nigeria_agricultural_export
GROUP BY month_no, month_name
ORDER BY month_no

--quaterly revenue
SELECT
	DATE_PART('DAY', export_date) AS export_quater,
	SUM(export_value) sum_of_revenue
FROM nigeria_agricultural_export
GROUP BY export_quater
ORDER BY export_quater

--dayily revenue
SELECT
	EXTRACT('DOW' FROM export_date) AS day_num,
	TO_CHAR(export_date, 'FMDay') AS day_of_week,
	SUM(export_value) sum_of_revenue,
	RANK() OVER(ORDER BY SUM(export_value) DESC)
FROM nigeria_agricultural_export
GROUP BY 1, 2
ORDER BY day_num

--Company with highest revenue
SELECT
	company,
	ROUND(SUM(export_value), -7) AS total_revenue
FROM nigeria_agricultural_export
GROUP BY company
ORDER BY total_revenue DESC

--company with the highest average revenue
SELECT
	company,
	ROUND(SUM(export_value)/ SUM(units_solds), -2) AS avg_revenue
FROM nigeria_agricultural_export
GROUP BY company
ORDER BY avg_revenue DESC

--company with the units sold
SELECT
	company,
	SUM(units_solds) AS units_sold
FROM nigeria_agricultural_export
GROUP BY company
ORDER BY units_sold DESC

--destination port revenue percent share
SELECT	
	destination_port,
	SUM(export_value) AS revenue,
	ROUND(SUM(export_value)/SUM(SUM(export_value)) OVER()*100, 2) percent_share
FROM nigeria_agricultural_export
GROUP BY destination_port
ORDER BY percent_share DESC

--Top exported product across port
SELECT *
FROM
	(SELECT
		destination_port,
		product_name,
		SUM(units_solds),
		ROW_NUMBER() OVER(PARTITION BY destination_port ORDER BY SUM(units_solds) DESC) AS rn
	FROM nigeria_agricultural_export
	GROUP BY destination_port, product_name
	ORDER BY 1, 3 DESC)
WHERE rn < 4