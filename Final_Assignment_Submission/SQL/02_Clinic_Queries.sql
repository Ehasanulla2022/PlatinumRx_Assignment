-- Clinic Management SQL Solutions
-- Q1 Revenue per sales channel
SELECT sales_channel, SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY sales_channel;

-- Q2 Top 10 valuable customers
SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- Q3 Month-wise revenue, expense, profit, status
WITH rev AS (
  SELECT MONTH(datetime) AS month_no, SUM(amount) AS revenue
  FROM clinic_sales WHERE YEAR(datetime)=2021 GROUP BY month_no
),
exp AS (
  SELECT MONTH(datetime) AS month_no, SUM(amount) AS expense
  FROM expenses WHERE YEAR(datetime)=2021 GROUP BY month_no
)
SELECT r.month_no, revenue, expense, revenue-expense AS profit,
CASE WHEN revenue-expense>=0 THEN 'Profitable' ELSE 'Not Profitable' END AS status
FROM rev r LEFT JOIN exp e ON r.month_no=e.month_no;

-- Q4 Most profitable clinic per city
WITH profit AS (
  SELECT c.city, c.cid,
         SUM(cs.amount) -
         COALESCE((SELECT SUM(amount) FROM expenses e WHERE e.cid=c.cid AND MONTH(e.datetime)=9), 0) AS profit
  FROM clinics c
  JOIN clinic_sales cs ON cs.cid=c.cid
  WHERE MONTH(cs.datetime)=9
  GROUP BY c.city, c.cid
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
  FROM profit
)
SELECT city, cid, profit FROM ranked WHERE rnk=1;

-- Q5 Second least profitable clinic per state
WITH profit AS (
  SELECT c.state, c.cid,
         SUM(cs.amount) -
         COALESCE((SELECT SUM(amount) FROM expenses e WHERE e.cid=c.cid AND MONTH(e.datetime)=9), 0) AS profit
  FROM clinics c
  JOIN clinic_sales cs ON cs.cid=c.cid
  WHERE MONTH(cs.datetime)=9
  GROUP BY c.state, c.cid
),
ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
  FROM profit
)
SELECT state, cid, profit FROM ranked WHERE rnk=2;
