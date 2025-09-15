use banking_project_db;

select * from accounts;
select * from branches;
select * from credit_cards;
select * from customer_feedback;
select * from customers;
select * from fraud_alerts;
select * from kyc_documents;
select * from loans;
select * from staff;
select * from transactions;

--  ======= Basic select and Filtering queries =======

-- 1. list all customers who live in thr city 'Mumbai'

select *
from customers
where city = 'Mumbai';

-- 2. get all accounts with balance greater than 100,000

select account_id,customer_id,balance
from accounts
where balance >100000;

-- 3. find transaction that happened on specific date '2025-07-01'

select account_id,amount,transaction_date
from transactions
where transaction_date >= '2025-07-11'
and transaction_date<'2025-07-12';

-- 4. list loans where repayment_status is 'pending'

select customer_id,loan_type,loan_amount,repayment_status
from loans
where repayment_status = 'ongoing';

-- 5. get credit cards with current usage greater than 80% of credit limit

select customer_id,card_type,credit_limit,current_usage
from credit_cards
where current_usage > 0.8 * credit_limit;

-- 6. list customers whose kyc status is not verified

select * from customers
where kyc_status != 'verified';

-- 7. get all active accounts (status= 'active')

select * from accounts
where status = 'active';

-- ======= Aggregations and Grouping Queries =======

-- 8. count customers by gender

select gender, count(*) as customer_count
from customers
group by gender;

-- 9. sum of loan amounts by loan type

select loan_type, sum(loan_amount) as sum_loan_amount
from loans
group by loan_type;

-- 10. Average account balance by branch

select branch_id, avg(balance) as avg_acc_balance
from accounts
group by branch_id;

-- 11. Total transaction amount per month

select year(transaction_date) as year, month(transaction_date)as month, sum(amount) as total_transactions
from transactions
group by year(transaction_date), month(transaction_date)
order by year,month;

-- 12. Number of accounts per customer

select customer_id,count(account_id) as accountt
from accounts
group by customer_id;

-- 13. count fraud alerts by severity

select severity,count(*) as alert_count
from fraud_alerts
group by severity;

-- 14. Average credit card utilization by card type

select card_type,avg(current_usage/credit_limit * 100) as card_usage
from credit_cards
group by card_type;

-- ======= joins ======= 

-- 15. Customers with their accounts

select
a.account_id,
c.first_name,
c.last_name,
c.customer_id,
a.account_type
from customers c 
join accounts a on c.customer_id = a.customer_id;

-- 16. Accounts with branch details

select 
a.account_id,
a.customer_id,
b.branch_id,
a.opening_date,
b.branch_name,
b.branch_city,
a.account_type,
a.balance
from accounts a 
join branches b on a.branch_id = b.branch_id;

-- 17. Transactions with account and customer info

select
t.transaction_id,
a.account_id,
c.first_name,
c.last_name,
t.transaction_date,
t.transaction_type,
t.amount,
c.customer_id
from transactions t 
join accounts a on t.account_id = a.account_id
join customers c on a.customer_id = c.customer_id;

-- 18. Loans with customer and staff info

select
l.customer_id,
c.first_name,
c.last_name,
s.staff_id,
s.branch_id,
l.loan_type,
l.loan_amount,
l.repayment_status
from loans l 
join customers c on l.customer_id = c.customer_id
join staff s on c.first_name = s.first_name and c.last_name = s.last_name;

-- 19. Fraud alerts with suspicious transactions

SELECT 
    t.transaction_id,
    t.transaction_date,
    t.account_id,
    t.transaction_type,
    t.amount,
    CASE 
        WHEN fa.transaction_id IS NOT NULL THEN 1
        ELSE 0
    END AS suspicious_flag,
    COALESCE(fa.alert_id, 'No Alert') AS alert_id,
    COALESCE(fa.alert_type, 'No Alert') AS alert_type,
    COALESCE(fa.resolved_by, 'Not Resolved') AS resolved_by
FROM transactions t
LEFT JOIN fraud_alerts fa
    ON t.transaction_id = fa.transaction_id;
    
-- 20. staff with branch and frauds resolved count

SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    b.branch_name,
    COUNT(f.transaction_id) AS resolved_frauds
FROM staff s
JOIN branches b
    ON s.branch_id = b.branch_id
LEFT JOIN fraud_alerts f
    ON s.staff_id = f.resolved_by
    AND f.resolution_status = 'Resolved' 
GROUP BY
    s.staff_id,
    s.first_name,
    s.last_name,
    b.branch_name;
    
-- 21. Customers with loans and credit cards

select
c.customer_id,
c.first_name,
c.last_name,
cc.card_id,
cc.credit_limit,
l.loan_id,
cc.current_usage,
l.loan_type,
l.loan_amount
from customers c 
join loans l on c.customer_id = l.customer_id
join credit_cards cc on c.customer_id = cc.customer_id;

-- 22. Customer feedback with sentiment and customer info

select 
c.customer_id,
concat(c.first_name,' ',c.last_name) as customer_name,
c.dob,
c.gender,
c.phone,
cf.feedback_id,
cf.sentiment
from customers c 
join customer_feedback cf on c.customer_id = cf.customer_id;

-- 23. Accounts with last transaction date

select
a.account_id,
a.customer_id,
max(t.transaction_date) as last_transaction_date 
from accounts a 
join transactions t on a.account_id = t.account_id
group by a.account_id,
a.customer_id;

-- 24. Branches with number of active accounts
SELECT
    b.branch_id,
    b.branch_name,
    COUNT(*) AS number_of_active_accounts
FROM accounts a
JOIN branches b ON a.branch_id = b.branch_id
WHERE a.status = 'active'
GROUP BY b.branch_id, b.branch_name;

-- 25. Loans with repayment status and customer risk profile

select
l.loan_id,
c.customer_id,
concat(c.first_name,' ',c.last_name) as customer_name,
l.repayment_status,
c.risk_profile
from loans l 
join customers c on l.customer_id = c.customer_id
order by l.repayment_status desc;

-- ======= Subqueries =======

-- 26.Customers with loans greater than average loan amount

select
 l.loan_id,
 c.customer_id,
 concat(c.first_name,' ',c.last_name),
 l.loan_amount
 from customers c 
 join loans l on c.customer_id = l.customer_id
 where l.loan_amount > (
 select avg(loan_amount)
 from loans
 );
 
 -- 27. Account with no transactions in last 6 months
 
select
    a.account_id,
    a.customer_id,
    t.transaction_id,
    t.transaction_date
from accounts a
join (
    select *
    from transactions
    where transaction_date >= date_sub(curdate(), interval 6 month)
) as t on a.account_id = t.account_id;


 -- 28. Customers with highest transaction amount in city
 
 select
 c.customer_id,
 concat(c.first_name,' ',c.last_name),
 c.city,
 t.transaction_id,
 t.amount
 from customers c 
 join accounts a on c.customer_id = a.customer_id
 join transactions t on a.account_id = t.account_id
 join(
      select
      c2.city,
      max(t2.amount) as max_amount
      from transactions t2
      join accounts a2 on t2.account_id = a2.account_id
      join customers c2 on a2.customer_id = c2.customer_id
      group by c2.city
      ) as city_max
      on c.city = city_max.city
      and t.amount =
      city_max.max_amount;
      
-- 29. suspicious transactions without fraud alert

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    t.transaction_id,
    t.account_id,
    t.suspicious_flag
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
WHERE t.account_id IN (
    SELECT t2.account_id
    FROM transactions t2
    WHERE t2.suspicious_flag = 1
);

-- 30. Customers with maximum credit card utilization

SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    cc.card_id, 
    cc.current_usage
FROM customers c
JOIN credit_cards cc ON c.customer_id = cc.customer_id
WHERE cc.current_usage = (
    SELECT MAX(current_usage) 
    FROM credit_cards
);

-- ======= Window Functions =======

-- 31. Running total of transactions per customer over time

select 
c.customer_id,
t.transaction_date,
t.amount,
sum(t.amount) over (
partition by c.customer_id
order by
t.transaction_date)
as running_total
from transactions t 
join accounts a on t.account_id = a.account_id
join customers c on a.customer_id = c.customer_id;

-- 32. Rank customers by total loan amount within branch

select
c.customer_id,
concat(c.first_name,' ',c.last_name) as customer_name,
a.branch_id,
sum(l.loan_amount) as total_loan,
rank() over (partition by a.branch_id
order by
sum(l.loan_amount) desc
) as loan_rank
from customers c  
join loans l on c.customer_id = l.customer_id
join accounts a on c.customer_id = a.customer_id
group by c.customer_id,customer_name,a.branch_id;

-- 33. Moving average of daily transaction amount

select
date(transaction_date)txn_date,
sum(amount) as daily_total,
avg(sum(amount)) over (
order by date(transaction_date)
rows between 6 preceding and current row)
as moving_avg_7day
from transactions
group by date(transaction_date)
order by txn_date;

-- 34. Top 3 highest transactions per account

select 
account_id,
transaction_id,
amount
from (
select t.*,
 row_number() over (
 partition by account_id
 order by amount desc)as rn
 from  transactions t 
 ) as ranked
 where rn <=3
 order by account_id,amount desc;
 
 -- ======= CTES and Recurive queries =======
 
 -- 35. Monthly new customer count trend
 
 WITH RECURSIVE months(d) AS (
    SELECT DATE(DATE_SUB(MIN(opening_date), INTERVAL DAY(MIN(opening_date)) - 1 DAY)) FROM accounts
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 MONTH)
    FROM months
    WHERE d < DATE(DATE_SUB(CURDATE(), INTERVAL DAY(CURDATE()) - 1 DAY))
),
agg AS (
    SELECT DATE(DATE_SUB(opening_date, INTERVAL DAY(opening_date) - 1 DAY)) AS d,
           COUNT(DISTINCT customer_id) AS new_customers
    FROM accounts
    GROUP BY d
)
SELECT m.d AS month_start, COALESCE(a.new_customers, 0) AS new_customers
FROM months m
LEFT JOIN agg a ON a.d = m.d
ORDER BY m.d;

-- 36. Fraud alert resolution_rate

WITH resolution_cte AS (
    SELECT 
        CAST(alert_date AS DATE) AS alert_day,
        COUNT(*) AS total_alerts,
        SUM(CASE WHEN resolution_status = 'resolved' THEN 1 ELSE 0 END) AS resolved_alerts,
        SUM(CASE WHEN resolution_status <> 'resolved' THEN 1 ELSE 0 END) AS unresolved_alerts
    FROM fraud_alerts
    GROUP BY CAST(alert_date AS DATE)
)
SELECT 
    alert_day,
    total_alerts,
    resolved_alerts,
    unresolved_alerts,
    CAST(resolved_alerts * 100.0 / total_alerts AS DECIMAL(5,2)) AS resolution_rate
FROM resolution_cte
ORDER BY alert_day;

-- 37. Customer feedback sentiment summary by month

with feedback_monthly as(
select
date_format(feedback_date,'%y-%m') as feedback_month,
sentiment,
count(*) as sentiment_count
from customer_feedback
group by feedback_month,sentiment
)
select
feedback_month,
sum(case when sentiment = 'positive' then sentiment_count else 0 end) as positive_count,
sum(case when sentiment = 'negative' then sentiment_count else 0 end) as negative_count,
sum(case when sentiment = 'neutral' then sentiment_count else 0 end) as neutral_count
from feedback_monthly
group by feedback_month
order by feedback_month;

-- 38. Yearly Staff Hiring Trend

WITH yearly_hires AS (
    SELECT 
        YEAR(join_date) AS hire_year,
        COUNT(*) AS total_hires
    FROM staff
    GROUP BY YEAR(join_date)
)
SELECT 
    hire_year,
    total_hires
FROM yearly_hires
ORDER BY hire_year;

-- ======= case statements =======

-- 39. Categorize customers by their risk profile based on balances & loans

select
c.customer_id,
concat(c.first_name,' ',c.last_name),
a.balance,
l.loan_amount,
case 
when a.balance < 5000 or 
l.loan_amount > 100000 then 'high risk'
when a.balance between 5000 and 20000 or 
l.loan_amount between 50000 and 100000 then 'medium risk'
else 'low risk'
end as risk_profile
from customers c
left join accounts a on 
c.customer_id = a.customer_id
left join loans l on
c.customer_id = l.customer_id;

-- 40. Account status with case (active,dormant,closed)

select
a.account_id,
a.customer_id,
a.balance,
max(t.transaction_date) as last_transaction_date,
case
when a.balance = 0 then 'closed'
when max(t.transaction_date) is null
or 
max(t.transaction_date) <
(curdate() - interval 365 day)
then 'dormant'
else 'active'
end as account_status
from accounts a 
left join transactions t on a.account_id = t.account_id
group by a.account_id,
a.customer_id,a.balance;

-- 41. Flag high-risk transactions with case

select
t.transaction_id,
t.account_id,
t.amount,
t.transaction_type,
t.transaction_date,
case 
when t.amount>100000 then 'high risk: large amount'
when t.amount <0 then 'high risk : negative value'
else 'normal'
end as risk_flag
from transactions t;

-- 42. Loan repayment status labels

select
loan_id,
customer_id,
loan_type,
loan_amount,
end_date,
repayment_status,
case
when repayment_status = 'closed' then 'on_time'
when repayment_status = 'ongoing' and end_Date < curdate() then 'overdue'
when repayment_status = 'ongoing' and end_Date > curdate() then 'upcoming loan'
else 'unknown'
end as repayment_label
from loans;

-- 43. Customer segment by transaction frequency

select
c.customer_id,
concat(c.first_name,' ',c.last_name) as customer_name,
count(t.transaction_id) as transaction_count,
case 
when
count(t.transaction_id) > 100 then 'platinum'
when 
count(t.transaction_id) between 50 and 100 then 'Gold'
when 
count(t.transaction_id) between 10 and 49 then 'Silver'
else 'Bronze'
end as customer_segment
from customers c
left join accounts a on c.customer_id = a.customer_id
left join transactions t on a.account_id = t.account_id
group by c.customer_id,customer_name;

-- ======= Data cleaning & Validation =======

-- 44. Customers with missing or invalid emails/phone

select
customer_id,
concat(first_name,' ',last_name) as customer_name,
email,
phone,
case 
when email is null or email not like '%_@_%._%' then 'invalid email'
when phone is null or phone not regexp '^[0-9]{10}$' then 'invalid phone'
else 'valid'
end as data_status
from customers;

-- 45. Accounts with negtive balance

select
account_id,
customer_id,
case
when balance < 0 then 'Negative balance'
else 'normal'
end as account_balance_status
from accounts;

set sql_safe_updates  = 0;
UPDATE accounts
SET balance = NULL
WHERE balance < 0;

-- 46. Expired KYC documents

select
customer_id,
concat(first_name,' ',last_name) as customer_name,
case
when kyc_status = 'verified' then 'valid kyc'
when kyc_status in ('pending','rejected') then 'expired/invalid'
else 'unknow/missing'
end as kyc_document_status
from customers;


-- ======= Performance & Index checks =======

-- 47. Show indexes on main tables

-- For Customers table
SHOW INDEX FROM customers;

-- For Accounts table
SHOW INDEX FROM accounts;

-- For Transactions table
SHOW INDEX FROM transactions;

-- For Loans table
SHOW INDEX FROM loans;

-- For CreditCards table 
SHOW INDEX FROM credit_cards;

-- For Fraud_alerts table
show index from Fraud_alerts;

-- For KYC_documents table
show index from KYC_documents;

-- For Loans table
show index from loans;

-- For Staff table
show index from staff; 

-- For Transactions table
show index from transactions;

-- 48. Identify slow queried

set global slow_query_log = 'on';
set global long_query_time = 2;

show variables like
'slow_query_log_file';

-- ======= Bonus/Miscellaneous Queries =======

-- 49. Count customer feedback sentiment categories

select
sentiment,
count(*) as total_feedback
from
customer_feedback
group by sentiment
order by total_feedback desc;

-- 50. Branches with highest loan disbursal amount

select
a.branch_id,
sum(l.loan_amount) as tot_disbursal_amount
from accounts a
left join loans l on a.customer_id = l.customer_id
group by a.branch_id
ORDER BY tot_disbursal_amount DESc;