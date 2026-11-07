-- 1. RFM view: score every customer on Recency, Frequency and Monetary value (1-5 each)
--    and assign a segment (Champions, Loyal, At Risk, Lost, New / Promising, Need Attention).

CREATE VIEW rfm AS
WITH cust AS (
  SELECT customer_id,
    CAST(julianday((SELECT date(MAX(order_date),'+1 day') FROM orders_clean))
         - julianday(MAX(order_date)) AS INT) AS recency_days,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(sales_bdt) AS monetary
  FROM orders_clean GROUP BY customer_id
),
scored AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r,
    NTILE(5) OVER (ORDER BY frequency)         AS f,
    NTILE(5) OVER (ORDER BY monetary)          AS m
  FROM cust
)
SELECT *,
  CASE
    WHEN r>=4 AND f>=4 THEN 'Champions'
    WHEN r>=3 AND f>=3 THEN 'Loyal'
    WHEN r>=4 AND f<=2 THEN 'New / Promising'
    WHEN r<=2 AND f>=3 THEN 'At Risk'
    WHEN r<=2 AND f<=2 THEN 'Lost'
    ELSE 'Need Attention'
  END AS segment
FROM scored; 

-- 2. Which customer segments drive revenue?
--    Result: Champions are ~25% of customers but ~63% of revenue.

SELECT segment,
  COUNT(*) AS customers,
  ROUND(AVG(recency_days)) AS avg_days_since_last_order,
  ROUND(AVG(frequency),1) AS avg_orders,
  ROUND(AVG(monetary)) AS avg_spend_bdt,
  ROUND(SUM(monetary)*100.0/(SELECT SUM(monetary) FROM rfm),1) AS pct_of_revenue
FROM rfm GROUP BY segment ORDER BY pct_of_revenue DESC;


-- 3. Who are our top 10 customers by spend? (JOIN between rfm and customers)
SELECT r.customer_id, c.customer_name, c.division, r.frequency, ROUND(r.monetary) AS total_spend_bdt
FROM rfm r JOIN customers c ON c.customer_id = r.customer_id
ORDER BY r.monetary DESC LIMIT 10;




-- 4. Do some acquisition channels bring better customers? (share of Champions per channel)
SELECT c.acquisition_channel,
  COUNT(*) AS customers,
  SUM(r.segment = 'Champions') AS champions,
  ROUND(100.0 * SUM(r.segment = 'Champions') / COUNT(*), 1) AS champion_pct
FROM rfm r JOIN customers c ON c.customer_id = r.customer_id
GROUP BY c.acquisition_channel ORDER BY champion_pct DESC;


-- 5. Cohort view: group customers by first-order month and measure how many
--    are active again 1, 2, 3... months later. month_index 0 = the first month (100%).
CREATE VIEW cohort_retention AS
WITH first_order AS (
  SELECT customer_id, MIN(order_date) AS first_date
  FROM orders_clean GROUP BY customer_id
),
activity AS (
  SELECT DISTINCT o.customer_id,
    STRFTIME('%Y-%m', f.first_date) AS cohort,
    (CAST(STRFTIME('%Y',o.order_date) AS INT) - CAST(STRFTIME('%Y',f.first_date) AS INT))*12
    + CAST(STRFTIME('%m',o.order_date) AS INT) - CAST(STRFTIME('%m',f.first_date) AS INT) AS month_index
  FROM orders_clean o JOIN first_order f USING (customer_id)
),
sizes AS (SELECT cohort, COUNT(*) AS cohort_size FROM activity WHERE month_index=0 GROUP BY cohort)
SELECT a.cohort, s.cohort_size, a.month_index,
  COUNT(*) AS active_customers,
  ROUND(100.0*COUNT(*)/s.cohort_size,1) AS retention_pct
FROM activity a JOIN sizes s USING (cohort)
GROUP BY a.cohort, a.month_index
ORDER BY a.cohort, a.month_index;




-- 6. Example cohorts (March 2024 and September 2024), first 6 months

SELECT * FROM cohort_retention
WHERE cohort IN ('2024-03','2024-09') AND month_index <= 6;




-- 7. Average retention curve across all cohorts (month 0 to 12)

SELECT month_index, ROUND(AVG(retention_pct),1) AS avg_retention_pct
FROM cohort_retention WHERE month_index <= 12
GROUP BY month_index ORDER BY month_index;









