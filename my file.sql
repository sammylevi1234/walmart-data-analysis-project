  select database();
  use walmart_db;
   
   /*business problems*/
   
   /* find different payment methode and number of transection,  quanty sold*/
select payment_method,
  count(*) as total_payment_method,
  sum(quantity) as number_of_quantity
from walmart
group by payment_method; 

/* identify the highest rated category in each branch, displaying the branch, category*/

select branch, category, 
avg(rating) as avg_rating
from walmart
group by branch, category 
order by avg_rating desc;

/*identify the business day for each branch based on the number of transections*/

SELECT * FROM (
    SELECT
        branch,
        DATE_FORMAT(date, '%W') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, day_name
) t
WHERE `rank` = 1
ORDER BY branch, no_transactions;

/* calculate the total of items sold per payment_method, list payment_method and tota;_quantit.*/
select payment_method,
  sum(quantity) as number_of_quantity
from walmart
group by payment_method; 

-- determine the average, minimum, and maximum rating of category fpr each city,list the city, average_rating and max_rating

select 
	city, category,
	min(rating)as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
from walmart 
group by city, category;

-- calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- list category and total_profit,ordered fromhighest to lowest profit
SELECT 
    category,
    SUM(total_amount) AS total_revenue,
    SUM(total_amount * profit_margin) AS profit
FROM walmart
GROUP BY category;

-- Determine the most common payment method for each branch. display branch and the preferred _payment_method
with cte
as
(select 
branch
payment_method,
count(*) as total_trans,
rank() over (partition by branch order by count(*) desc) as `rank`
from walmart
group by branch, payment_method
)
select *
from cte 
where `rank` = 1;

-- categories sales into 3 groups morning, afternoon, evening
-- find out each shift and number of invoices 
 
   SELECT 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(invoice_id) AS number_of_invoices
FROM walmart
GROUP BY shift
ORDER BY number_of_invoices DESC;

-- identify  5 branch with highest decrease ratio in revenue compare to last ( current year 2023 and last year 2022)

-- 2022 sale
with revenue_2022
as 
(SELECT 
    branch,
    SUM(total_amount) AS revenue
FROM walmart
WHERE YEAR(date) = 2022
GROUP BY branch
),
revenue_2023
as
(
SELECT 
    branch,
    SUM(total_amount) AS revenue
FROM walmart
WHERE YEAR(date) = 2023
GROUP BY branch
) 
 select 
 ls.branch,
 ls.revenue as last_year_revenue,
 cs.revenue as current_year_revenue,
  round(
  (CAST(ls.revenue AS DECIMAL(12,2)) - CAST(cs.revenue AS DECIMAL(12,2))) 
    / NULLIF(CAST(ls.revenue AS DECIMAL(12,2)), 0) * 100,
    2) as revenue_decrease_ratio
 from revenue_2022 as ls
 join
 revenue_2023 as cs
 on ls.branch = cs.branch
 where
 ls.revenue > cs.revenue
 order by revenue_decrease_ratio desc
 limit 5
 
 