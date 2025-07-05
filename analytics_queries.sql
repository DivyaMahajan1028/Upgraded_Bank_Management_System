use Bank_management_system ;
SHOW TABLES;
set sql_safe_updates = 0

SELECT * FROM customer_info;
-- DIVYA	3825	1145000
-- RAM	    9147	53000
-- SITA	    4315	25200
-- SIMRAN	6605	5000
-- KRISH	5541	400
-- ROHAN	4309	3800
-- DIVYA	1760	552800
-- OM	    3131	6000
-- MAYA	    4371	1001
-- PRIYA	3673	2000

SELECT * FROM transaction_log;
-- 1	ROHAN	4309	credit	800	2025-07-04 17:39:56
-- 2	ROHAN	4309	credit	5000	2025-07-04 17:40:01
-- 3	ROHAN	4309	credit	5000	2025-07-04 17:40:14
-- 4	ROHAN	4309	debit	5000	2025-07-04 17:40:28
-- 5	ROHAN	4309	debit	2000	2025-07-04 17:40:35
-- 6	DIVYA	1760	credit	100000	2025-07-04 17:44:58
-- 7	DIVYA	1760	credit	2000	2025-07-04 17:45:21
-- 8	DIVYA	1760	debit	50000	2025-07-04 17:46:13
-- 9	DIVYA	1760	credit	500800	2025-07-04 17:46:28
-- 10	OM	    3131	credit	8000	2025-07-04 17:47:00
-- 11	OM	    3131	debit	2000	2025-07-04 17:47:27
-- 12	MAYA	4371	credit	200	    2025-07-04 17:48:05
-- 13	MAYA	4371	credit	300	    2025-07-04 17:48:11
-- 14	MAYA	4371	credit	300	    2025-07-04 17:48:22
-- 15	MAYA	4371	credit	1	    2025-07-04 17:48:57
-- 16	MAYA	4371	credit	400	    2025-07-04 17:49:04
-- 17	MAYA	4371	credit	100	    2025-07-04 17:49:08
-- 18	MAYA	4371	debit	300	    2025-07-04 17:49:14
-- 19	PRIYA	3673	credit	1000	2025-07-04 18:55:18
-- 20	PRIYA	3673	credit	2000	2025-07-04 18:55:34
-- 21	PRIYA	3673	debit	1000	2025-07-04 18:55:44
					

-- Rank Customers By Total Credits (using CTE with 	WINDOW FUNCTION)
WITH credit_totals AS (
    SELECT name, SUM(amount) AS total_credit
    FROM transaction_log
    WHERE action = 'credit'
    GROUP BY name
)
SELECT name, total_credit,
    RANK() OVER (ORDER BY total_credit DESC)
    AS credit_rank
from credit_totals;    

-- DIVYA	602800	1
-- ROHAN	10800	2
-- OM	    8000	3
-- PRIYA	3000	4
-- MAYA	    1301	5

-- Customer With Withdrawals Above Their Own Average --(CORRELATED SUBQUERY)
SELECT DISTINCT name
FROM transaction_log t1
WHERE t1.action = 'debit'
    AND t1.amount > (
    SELECT AVG(amount)
    FROM transaction_log t2
    where t2.name = t1.name AND t2.action = 'debit');

    -- ROHAN
    
    
-- Ranking by withdrawals Per Customer

WITH user_withdrawals AS (
    SELECT name, SUM(amount) AS total_withdrawn
    FROM transaction_log
    WHERE action = 'debit'
    GROUP BY name
)
SELECT name, total_withdrawn,
       DENSE_RANK() OVER (ORDER BY total_withdrawn DESC) AS withdrawal_rank
FROM user_withdrawals;
-- DIVYA	50000	1
-- ROHAN	7000	2
-- OM	    2000	3
-- PRIYA	1000	4
-- MAYA	    300	    5

-- TOP 3 FREQUENT CUSTOMERS (WITH CTE)
WITH customer_counts AS (
SELECT name, count(*) AS count_number 
FROM transaction_log
GROUP BY name 
)
SELECT * FROM customer_counts ORDER BY count_number DESC; 
-- MAYA	    7
-- ROHAN	5
-- DIVYA	4
-- PRIYA	3
-- OM	    2

-- Running Balance over time for for a specific user (WINDOW FUNCTION) 
SELECT name, action, amount, timestamp, 
    sum(CASE WHEN action = 'CREDIT' THEN amount
    ELSE -amount END)
    OVER (PARTITION BY name ORDER BY timestamp) AS 
    running_balance FROM transaction_log
    where name = 'DIVYA'
    ORDER BY timestamp;
    -- DIVYA	credit	100000	2025-07-04 17:44:58	100000
    -- DIVYA	credit	2000	2025-07-04 17:45:21	102000
    -- DIVYA	debit	50000	2025-07-04 17:46:13	52000
    -- DIVYA	credit	500800	2025-07-04 17:46:28	552800
    
-- Last 3 Transaction Per User (ROW_NUMBER) (CTE + WINDOW FUNCTION)
WITH txn_rank AS (
    select * , ROW_NUMBER () OVER (PARTITION BY name ORDER BY timestamp DESC) AS rn
    from transaction_log)
    SELECT * from txn_rank where rn <= 3;
9	DIVYA	1760	credit	500800	2025-07-04 17:46:28	1
8	DIVYA	1760	debit	50000	2025-07-04 17:46:13	2
7	DIVYA	1760	credit	2000	2025-07-04 17:45:21	3
18	MAYA	4371	debit	300	    2025-07-04 17:49:14	1
17	MAYA	4371	credit	100	    2025-07-04 17:49:08	2
16	MAYA	4371	credit	400	    2025-07-04 17:49:04	3
11	OM	    3131	debit	2000	2025-07-04 17:47:27	1
10	OM	    3131	credit	8000	2025-07-04 17:47:00	2
21	PRIYA	3673	debit	1000	2025-07-04 18:55:44	1
20	PRIYA	3673	credit	2000	2025-07-04 18:55:34	2
19	PRIYA	3673	credit	1000	2025-07-04 18:55:18	3
5	ROHAN	4309	debit	2000	2025-07-04 17:40:35	1
4	ROHAN	4309	debit	5000	2025-07-04 17:40:28	2
3	ROHAN	4309	credit	5000	2025-07-04 17:40:14	3
    
-- AVERAGE DAILY TRANSACTION VOLUME (NESTED SUBQUERIES)
-- (TOTAL TRANSACTIONS GROUP BY DATA)
SELECT txn_date, count(*) AS txn_count
FROM (
   SELECT DATE (timestamp) AS txn_date
   FROM transaction_log
   ) AS daily
   GROUP BY txn_date;
-- 2025-07-04	21