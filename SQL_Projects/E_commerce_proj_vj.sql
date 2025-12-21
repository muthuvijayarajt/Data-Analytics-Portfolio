USE ecommerce_project_rich;

select * from categories;
select * from inventory;
select * from order_items;
select * from orders;
select * from payments;
select * from products;
select * from reviews;
select * from shipments;
select * from suppliers;
select * from users;

-- ======= Basic select and filtering (7) =======

-- 1. List all users from a specific city (Chennai)

select
*
from users
where city = 'Chennai'
order by first_name asc;

-- 2. Get products with price greater than a specific value (5000)

select
product_id,
product_name,
price
from products 
where price >= 5000
order by price;

-- 3. Find orders placed on a specific date (25-04-25)

select 
order_id,
user_id,
date(order_date)
from orders 
where date(order_date) = '25-04-25'
order by order_id;

-- 4. List products with stock less than a threshold

select
product_id,
stock
from inventory
where stock <= 10
order by product_id;

-- 5. Get users who placed more than a certain number of orders (5)

SELECT *
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING COUNT(order_id) >= 5
);

-- 6. Customers with missing or invalid email addresses

SELECT *
FROM users
WHERE email IS NULL
   OR email NOT LIKE '%_@_%._%';

-- 7. Get all active orders (status = 'completed' or 'shipped')

select * 
from orders 
where status in ('delivered' ,'shipped');

-- ======= Aggregations and Grouping (7) =======

-- 8. Count users by gender

select 
gender,count(user_id) as count_of_gender
from users 
group by gender;

-- 9. Sum of order amounts by month

select
month(order_date) as order_month,
sum(total_amount) as total_amt
from orders 
group by order_month;

-- 10. Average product price by category

select
category_id,
avg(price) as avg_product_price
from products
group by category_id;

-- 11. Total quantity sold per product

SELECT product_id,
       COUNT(product_id) AS sold_product
FROM order_items
GROUP BY product_id
ORDER BY sold_product DESC;


-- 12. Number of orders per customer

select
user_id,
count(order_id) as customer_order
from orders
group by user_id;

-- 13. Count reviews by rating

SELECT rating,
       COUNT(review_id) AS count_reviews
FROM reviews
GROUP BY rating;


-- 14. Average discount applied per product category

select
category_id,
avg(discount) as avg_product_discount
from products
group by category_id;

-- ======= joins (11) ======= 

-- 15. Users with their orders

select
u.user_id,
concat(u.first_name,' ',u.last_name) as customer_name,
o.order_id,
o.order_date,
o.total_amount
from users u 
join orders o on u.user_id = o.user_id;

-- 16. Orders with product details

select
o.order_id,
o.user_id,
oi.product_id,
p.product_name,
p.category_id,
p.price,
p.discount
from orders o 
join order_items oi on o.order_id = oi.order_id
join products p on  oi.product_id = p.product_id
order by o.order_id, p.product_name;

-- 17. Payments with user and order info

select 
u.user_id,
concat(u.first_name,' ',u.last_name)as user_name,
o.order_id,
p.amount,
p.payment_date,
p.method,
p.status
from users u 
join orders o on u.user_id = o.user_id
join payments p on o.order_id = p.order_id
order by user_name,p.amount;

-- 18. Shipments with order and user info

select
s.shipment_id,
o.user_id,
concat(u.first_name,' ',u.last_name) as user_name,
u.email,
u.phone,
s.shipped_date,
s.delivery_Date,
s.status
from shipments s 
join orders o on s.order_id = o.order_id
join users u on o.user_id = u.user_id
order by s.shipment_id;

-- 19. Reviews with product and user info

select
r.review_id,
r.review_date,
p.product_name,
r.comment,
r.rating, 
concat(u.first_name,' ',u.last_name) as user_name,
u.user_id,
u.phone
from reviews r 
join products p on r.product_id = p.product_id
join users u on r.user_id = u.user_id
order by r.review_id,r.rating;

-- 20. Products with supplier details

select
p.product_id,
p.product_name,
p.supplier_id,
s.supplier_name,
s.contact_email,
s.phone,
s.address,
s.city
from products p 
join suppliers s on p.supplier_id = s.supplier_id
order by p.supplier_id,p.product_id;

-- 21. Users with products they purchased

select
    u.user_id,
    concat(u.first_name, ' ', u.last_name) as user_name,
    p.category_id,
    p.product_name,
    p.price,
    p.created_at,
    u.phone,
    o.order_id,
    o.order_date
from users u
join orders o on u.user_id = o.user_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
order by u.user_id, o.order_date, p.product_name;

-- 22. Orders with payment status and shipment status

select
o.order_id,
concat(u.first_name,' ',u.last_name) as user_name,
p.method as payment_method,
p.amount as payment_amount,
p.payment_date,
s.tracking_number,
s.shipped_date,
s.delivery_date,
s.status
from orders o 
join payments p on o.order_id = p.order_id
join shipments s on o.order_id = s.order_id
join users u on o.user_id = u.user_id
order by o.order_id,p.payment_id;

-- 23. Orders with last payment date

select
o.user_id,
p.order_id,
max(p.payment_date) as last_paymnt_date
from orders o 
join payments p on o.order_id = p.order_id
group by o.user_id,p.order_id;

-- 24. Categories with number of products sold

select
c.category_name,
count(p.product_id) as products_sold
from categories c
join products p on c.category_id = p.category_id
group by c.category_id, c.category_name;

-- 25. Orders with product category and total amount

select
    o.user_id,
    c.category_name,
    sum(oi.quantity * oi.price) as category_total_amount
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
join categories c on p.category_id = c.category_id
group by o.user_id, c.category_name;

-- ======= Subqueries (5) =======

-- 26. Users who spent more than the average total spending

select
u.user_id,
concat(u.first_name,' ',u.last_name) as user_name,
sum(o.total_amount) as total_spent
from users u 
join orders o on u.user_id = o.user_id
group by u.user_id,user_name
having sum(o.total_amount) > 
(
select avg(user_total)
orders from (
select
sum(o2.total_amount) as user_total
from orders o2
group by o2.user_id
) as user_totals
);

-- 27. Products that have never been ordered

select
p.product_id,
p.product_name,
p.price
from products p 
where p.product_id not in (
select oi.product_id
from order_items oi);

-- 28. Users with the highest total order amount in city

SELECT 
    t.user_id,
    t.user_name,
    t.city,
    t.total_spent
FROM (
    SELECT 
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS user_name,
        u.city,
        SUM(o.total_amount) AS total_spent
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.city, u.first_name, u.last_name
) t
WHERE t.total_spent = (
    SELECT MAX(t2.total_spent)
    FROM (
        SELECT 
            u2.user_id,
            u2.city,
            SUM(o2.total_amount) AS total_spent
        FROM users u2
        JOIN orders o2 ON u2.user_id = o2.user_id
        GROUP BY u2.user_id, u2.city
    ) t2
    WHERE t2.city = t.city
);

-- 29. Orders without any shipment yet

select
o.order_id,
o.order_date,
o.total_amount
from orders o 
 where o.order_id not in (
select 
s.order_id
from shipments s);

-- 30. Products with maximum discount applied

SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.discount
FROM products p
WHERE p.discount > (
    SELECT 25   -- or 0.25 depending on your data
);

-- ======= Window Functions (4) =======

-- 31. Running total of orders per user over time

select
u.user_id,
o.order_date,
o.total_amount,
sum(o.total_amount) over (
partition by u.user_id order by o.order_date)
as running_total
from users u
join orders o on u.user_id = o.user_id;

-- 32. Rank products by total sales within each category

select 
    t.category_id,
    t.category_name,
    t.total_sales,
    rank() over (order by t.total_sales desc) as sales_rank
from (
    select 
        p.category_id,
        c.category_name,
        sum(o.total_amount) as total_sales
    from products p
    join categories c on p.category_id = c.category_id
    join order_items oi on p.product_id = oi.product_id
    join orders o on oi.order_id = o.order_id
    group by p.category_id, c.category_name
) t;


-- 33. Moving average of daily revenue

select
date(payment_date) as paying_date,
sum(amount)as daily_total,
avg(sum(amount)) over (order by date (payment_date)
rows between 6 preceding and current row) as daily_mov_avg
from payments
group by date(payment_date)
order by paying_date;

-- 34. Top 3 highest orders per user

select * 
from(
select
u.user_id,
concat(u.first_name,' ',u.last_name) as user_name,
o.order_id,
o.total_amount,
o.order_date,
row_number() over(
partition by u.user_id order by o.total_amount desc)
as order_rank
from users u 
join orders o on u.user_id = o.user_id
) as ranked_orders
where order_rank<= 3;

-- ======= Ctes & Recursive Queries(4) ======= 

-- 35. Monthly New user sign_up trend

with monthly_signups as (
    select
        date_format(created_at, '%Y-%m') as signup_month,
        count(user_id) as new_users
    from users
    group by date_format(created_at, '%Y-%m')
)
select
    signup_month,
    new_users
from monthly_signups
order by signup_month;

-- 36. Shipment delivery timeline

with delivery_times as (
    select
        o.order_id,
        date_format(o.order_date, '%Y-%m') as order_month,
        datediff(s.shipped_date, o.order_date) as delivery_days
    from orders o
    join shipments s on o.order_id = s.order_id
    where s.shipped_date is not null
)
select
    order_month,
    avg(delivery_days) as avg_delivery_days,
    min(delivery_days) as fastest_delivery,
    max(delivery_days) as slowest_delivery
from delivery_times
group by order_month
order by order_month;

-- 37. Average review rating per month

with review_rating as (
select 
avg(rating) as avg_rating_permonth,
date_format(review_date,'%y-%m') as per_month
from reviews 
group by per_month
)
select 
avg_rating_permonth,
per_month
from review_rating
order by per_month;

-- 38. Generate a sequence of months and join with orders(recursive ctes)
 
     WITH RECURSIVE month_series AS (
  -- anchor: first day of the earliest order month
  SELECT DATE_SUB(DATE(MIN(order_date)), INTERVAL DAY(DATE(MIN(order_date))) - 1 DAY) AS month_start
  FROM orders
  UNION ALL
  SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
  FROM month_series
  WHERE month_start < (
    SELECT DATE_SUB(DATE(MAX(order_date)), INTERVAL DAY(DATE(MAX(order_date))) - 1 DAY)
    FROM orders
  )
)
SELECT
  DATE_FORMAT(ms.month_start, '%Y-%m') AS month,
  COUNT(o.order_id) AS total_orders
FROM month_series ms
LEFT JOIN orders o
  ON o.order_date >= ms.month_start
  AND o.order_date < DATE_ADD(ms.month_start, INTERVAL 1 MONTH)
GROUP BY ms.month_start
ORDER BY ms.month_start;

-- ======= Advanced Filtring(5) =======

-- 39. Find users with more than 5 orders in the last 30days

SELECT user_id, COUNT(order_id) AS orders_last_30_days
FROM orders
WHERE order_date >= DATE_SUB('2025-01-31', INTERVAL 30 DAY)
GROUP BY user_id
HAVING COUNT(order_id) > 5;

-- 40. List products with stock below 10 and price above 5000

SELECT
    i.product_id,
    p.product_name,
    i.stock,
    p.price
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE i.stock < 10
  AND p.price > 5000;

-- 41. Find orders with total amount greater than 50000

select
o.order_id,o.user_id,
o.total_amount,concat(u.first_name,' ',u.last_name) as user_name
from orders o
join users u on o.user_id = u.user_id
where o.total_amount>= 50000;

-- 42. Shipment delivery status report

select
shipment_id,
order_id,
delivery_date,
status
from shipments
where status in ('delayed','returned','in transit');

-- 43. Find users who have never left a review

select
u.user_id,
concat(u.first_name,' ',u.last_name) as user_name,
u.email
from users u 
where not exists (
select 1
from reviews r 
where r.user_id = u.user_id);

-- ======= Data cleaning & Validation (3) =======

-- 44. Users with missing or invalid phone numbers

select
user_id,
concat(first_name,' ',last_name) as user_name,
phone as phone_number,
case 
when phone is null or phone not regexp '^[0-9]{10}$' then 'invalid'
else 'valid'
end as phone_number_status
from users;

-- 45. Products with low stock quantity

select
product_id,
stock
from inventory
where stock <25;

-- 46. Orders with inconsistent total amounts

select
o.order_id,
o.user_id,
o.total_amount,
sum(oi.quantity * oi.price) as calculated_total,
case 
when o.total_amount <> sum(oi.quantity * oi.price) then 'inconsistent'
else 'consistent'
end as total_status
from orders o 
join order_items oi on o.order_id = oi.order_id
group by o.order_id,o.user_id,o.total_amount
having total_status = 'inconsistent';

-- ======= Performance & Index checks (2) =======

-- 47. Show indexes on main tables

SHOW INDEXES FROM users;

SHOW INDEXES FROM orders;

SHOW INDEXES FROM products;

SHOW INDEXES FROM inventory;

SHOW INDEXES FROM order_items;

SHOW INDEXES FROM reviews;

SHOW INDEXES FROM shipments;

SHOW INDEXES FROM payments;

SHOW INDEXES FROM categories;

SHOW INDEXES FROM suppliers;

-- 48. Identify slow queries

set global slow_query_log = 'on';
set global long_query_time = 2;

show variables like
'slow_query_log_file';

-- ======= Bonus/Miscellaneous queries (2) ======= 

-- 49. Count reviews(positive,neutral,negative)

select
rating,
count(review_id) as category,
case
when rating >= 4 then 'positive'
when rating = 3 then 'neutral'
else 'negative'
end as status_table
from reviews 
group by rating
order by rating desc;

-- 50. Categories with highest total sales revenue

SELECT
    c.category_id,
    c.category_name,
    SUM(oi.quantity * p.price) AS total_sales
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC
LIMIT 5; 

