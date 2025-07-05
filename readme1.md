🚀 Upgraded Bank Management System with Python & MySQL 💳📊

An all-in-one Bank Management System that combines powerful Python logic with advanced SQL queries. This upgraded version goes beyond basic banking operations — adding transaction logging, SQL analytics, and professional data tracking using CTEs, window functions, and subqueries.

🧰 Tech Stack

🐍 Python 3.x

🛢️ MySQL (with MySQL Workbench)

🧩 MySQL Connector (Python)

🖥️ VS Code / OBS Studio (for video demo)

💡 Key Features

✅ Register New Customers with Auto-PIN Generation✅ Authenticate Users with PIN Login✅ Credit & Debit Transactions with Validation✅ Track All Transactions in a SQL Table✅ Transaction History with Timestamp Logs✅ Real-time Balance Updates✅ Secure Account Deletion Option✅ Full SQL Analytical Queries (CTE, Window Function, Subquery)

🗃️ Database Schema

🔸 customer_info

CREATE TABLE IF NOT EXISTS customer_info (
  Name VARCHAR(20),
  pin INT,
  Balance INT DEFAULT 0
);

🔸 transaction_log

CREATE TABLE IF NOT EXISTS transaction_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20),
  pin INT,
  action VARCHAR(10),
  amount INT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

📊 Advanced SQL Queries

These queries demonstrate how your project uses real-world Data Analytics features inside a simple bank system.

1️⃣ Rank Customers by Total Credits (CTE + Window Function)

WITH credit_totals AS (
  SELECT name, SUM(amount) AS total_credit
  FROM transaction_log
  WHERE action = 'credit'
  GROUP BY name
)
SELECT name, total_credit,
  RANK() OVER (ORDER BY total_credit DESC) AS credit_rank
FROM credit_totals;

2️⃣ Customers With Withdrawals Above Their Own Average (Correlated Subquery)

SELECT DISTINCT name
FROM transaction_log t1
WHERE t1.action = 'debit'
  AND t1.amount > (
    SELECT AVG(amount)
    FROM transaction_log t2
    WHERE t2.name = t1.name AND t2.action = 'debit'
);

3️⃣ Ranking by Withdrawals Per Customer (CTE + DENSE_RANK)

WITH user_withdrawals AS (
  SELECT name, SUM(amount) AS total_withdrawn
  FROM transaction_log
  WHERE action = 'debit'
  GROUP BY name
)
SELECT name, total_withdrawn,
       DENSE_RANK() OVER (ORDER BY total_withdrawn DESC) AS withdrawal_rank
FROM user_withdrawals;

4️⃣ Top 3 Frequent Customers (CTE)

WITH customer_counts AS (
  SELECT name, COUNT(*) AS count_number
  FROM transaction_log
  GROUP BY name
)
SELECT * FROM customer_counts ORDER BY count_number DESC LIMIT 3;

5️⃣ Running Balance Over Time for a Specific User (Window Function)

SELECT name, action, amount, timestamp,
  SUM(CASE WHEN action = 'CREDIT' THEN amount ELSE -amount END)
    OVER (PARTITION BY name ORDER BY timestamp) AS running_balance
FROM transaction_log
WHERE name = 'DIVYA'
ORDER BY timestamp;

6️⃣ Last 3 Transactions Per User (CTE + ROW_NUMBER)

WITH txn_rank AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY name ORDER BY timestamp DESC) AS rn
  FROM transaction_log
)
SELECT * FROM txn_rank WHERE rn <= 3;

7️⃣ Average Daily Transaction Volume (Nested Subqueries)

SELECT txn_date, COUNT(*) AS txn_count
FROM (
  SELECT DATE(timestamp) AS txn_date
  FROM transaction_log
) AS daily
GROUP BY txn_date;

🎬 How to Present the Project (Video Demo)

🎤 Record a voice-narrated screen demo explaining:

👤 New User Registration

➕ Deposit / ➖ Withdrawal Process

📄 Transaction History (with live balance)

📊 SQL Analytics directly in MySQL

🎥 Tools to record video:

OBS Studio (recommended)

Windows + G (Quick Recording)

🗣️ Tip: Speak clearly, explain each step simply, and showcase your SQL skills too!

📁 Recommended GitHub Folder Structure

Bank_Management_Upgrade/
├── upgrade_bank_system.py
├── README.md
└── analytics_queries.sql (optional but useful)

👤 About the Developer

👩‍💻 Divya Mahajan🚀 Transitioning into IT with strong skills in Python & SQL🌱 On a mission to build impactful and analytical projects🔗 Exploring Data Science, Cloud, and FinTech

⭐ If you like the project, don’t forget to star it and leave a comment!

🧠 "Your skills matter more than your background. Keep building."

