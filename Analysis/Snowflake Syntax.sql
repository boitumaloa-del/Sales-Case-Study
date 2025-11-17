SELECT
  *
FROM
  "CASE_STUDY"."SALES"."SALES_ANALYSIS";

DESC TABLE "CASE_STUDY"."SALES"."SALES_ANALYSIS";
  
-- Check row counts
SELECT COUNT(*) AS total_rows
FROM "CASE_STUDY"."SALES"."SALES_ANALYSIS";

--NULL Check Query
SELECT
  COUNT_IF("DATE" IS NULL) AS null_dates,
  COUNT_IF("SALES" IS NULL) AS null_sales,
  COUNT_IF("COST_OF_SALES" IS NULL) AS null_cost,
  COUNT_IF("QUANTITY_SOLD" IS NULL) AS null_qty
FROM "CASE_STUDY"."SALES"."SALES_ANALYSIS";


--Updated Duplicate Check Query

SELECT "DATE", "SALES", "COST_OF_SALES", "QUANTITY_SOLD", COUNT(*) AS duplicate_count
FROM "CASE_STUDY"."SALES"."SALES_ANALYSIS"
GROUP BY "DATE", "SALES", "COST_OF_SALES", "QUANTITY_SOLD"
HAVING COUNT(*) > 1;

--Create a Clean View with Derived Metrics
CREATE OR REPLACE VIEW "CASE_STUDY"."SALES"."SALES_METRICS_VIEW" AS
SELECT
  TO_DATE("DATE", 'DD/MM/YYYY') AS sales_date,
  "SALES" AS sales_value,
  "COST_OF_SALES" AS cost_value,
  "QUANTITY_SOLD" AS quantity,
  
  -- Derived Metrics
  ROUND("SALES" / NULLIF("QUANTITY_SOLD", 0), 2) AS unit_price,
  ROUND("SALES" - "COST_OF_SALES", 2) AS gross_profit,
  ROUND((("SALES" - "COST_OF_SALES") / NULLIF("SALES", 0)) * 100, 2) AS gross_profit_pct,
  ROUND((("SALES" - "COST_OF_SALES") / NULLIF("QUANTITY_SOLD", 0)), 2) AS gross_profit_per_unit
FROM "CASE_STUDY"."SALES"."SALES_ANALYSIS";

--Preview the Metrics
SELECT *
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
ORDER BY sales_date;

--filter for specific months, trends, or outliers
-- Example: Find top 10 days with highest gross profit %
SELECT *
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
ORDER BY gross_profit_pct DESC;

--Revised Promotion Flag Query
SELECT *
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE unit_price < (
    SELECT AVG(unit_price) * 0.95 FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
)
AND quantity > (
    SELECT AVG(quantity) * 1.2 FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
)
ORDER BY sales_date;

--Baseline vs Promotion Averages
--August 2014 Promotion
--Baseline (before promotion)
SELECT 
  AVG(UNIT_PRICE) AS baseline_price,
  AVG(QUANTITY) AS baseline_qty
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE SALES_DATE BETWEEN '2014-08-10' AND '2014-08-25';
--Promotion period
SELECT 
  AVG(UNIT_PRICE) AS promo_price,
  AVG(QUANTITY) AS promo_qty
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE SALES_DATE BETWEEN '2014-08-26' AND '2014-09-08';

--September–October 2015 Promotion
--Baseline
SELECT 
  AVG(UNIT_PRICE) AS baseline_price,
  AVG(QUANTITY) AS baseline_qty
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE SALES_DATE BETWEEN '2015-09-10' AND '2015-09-24';
--Promotion
SELECT 
  AVG(UNIT_PRICE) AS promo_price,
  AVG(QUANTITY) AS promo_qty
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE SALES_DATE BETWEEN '2015-09-25' AND '2015-10-06';

--November 2015 Promotion
--Baseline
SELECT 
  AVG(UNIT_PRICE) AS baseline_price,
  AVG(QUANTITY) AS baseline_qty
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE SALES_DATE BETWEEN '2015-11-10' AND '2015-11-25';

--Promotion
SELECT 
  AVG(UNIT_PRICE) AS promo_price,
  AVG(QUANTITY) AS promo_qty
FROM "CASE_STUDY"."SALES"."SALES_METRICS_VIEW"
WHERE SALES_DATE BETWEEN '2015-11-26' AND '2015-11-29';

SELECT * FROM CASE_STUDY.SALES.SALES_METRICS_VIEW;

