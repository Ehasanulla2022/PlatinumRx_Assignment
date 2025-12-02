-- Hotel Management System SQL Solutions
-- Q1
SELECT u.user_id, b.room_no, b.booking_date
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (SELECT MAX(b2.booking_date) FROM bookings b2 WHERE b2.user_id = u.user_id);

-- Q2
SELECT b.booking_id, SUM(i.item_rate * bc.item_quantity) AS total_amount
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(b.booking_date)=11 AND YEAR(b.booking_date)=2021
GROUP BY b.booking_id;

-- Q3
SELECT bc.bill_id, SUM(i.item_rate * bc.item_quantity) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id=i.item_id
WHERE MONTH(bc.bill_date)=10 AND YEAR(bc.bill_date)=2021
GROUP BY bc.bill_id
HAVING bill_amount>1000;

-- Q4
WITH monthly AS (
  SELECT MONTH(bc.bill_date) AS month_no, i.item_name, SUM(bc.item_quantity) AS qty
  FROM booking_commercials bc
  JOIN items i ON bc.item_id=i.item_id
  WHERE YEAR(bc.bill_date)=2021
  GROUP BY month_no, item_name
),
ranked AS (
  SELECT *, 
  RANK() OVER (PARTITION BY month_no ORDER BY qty DESC) AS max_rnk,
  RANK() OVER (PARTITION BY month_no ORDER BY qty ASC) AS min_rnk
  FROM monthly
)
SELECT month_no, item_name, qty, 'Most Ordered' FROM ranked WHERE max_rnk=1
UNION ALL
SELECT month_no, item_name, qty, 'Least Ordered' FROM ranked WHERE min_rnk=1;

-- Q5
WITH bills AS (
  SELECT bc.bill_id, b.user_id, MONTH(bc.bill_date) AS month_no,
         SUM(i.item_rate * bc.item_quantity) AS bill_amount
  FROM booking_commercials bc
  JOIN bookings b ON bc.booking_id=b.booking_id
  JOIN items i ON bc.item_id=i.item_id
  WHERE YEAR(bc.bill_date)=2021
  GROUP BY bill_id, user_id, month_no
),
ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY month_no ORDER BY bill_amount DESC) AS rnk
  FROM bills
)
SELECT month_no, user_id, bill_id, bill_amount FROM ranked WHERE rnk=2;
