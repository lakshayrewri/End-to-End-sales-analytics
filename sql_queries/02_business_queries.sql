--1. Find top 3 customers based on total sales within every region.

WITH top_customers AS (
SELECT c.region, o.customer_id,
       SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.region, o.customer_id
)
SELECT * 
FROM(
SELECT *,
RANK() OVER(
            PARTITION BY region
            ORDER BY total_sales DESC
       ) AS rnk
FROM top_customers
) t
WHERE rnk <= 3;

--2. Identify the top 2 products in each category based on total profit.

WITH top_products AS (
SELECT p.category, o.product_id,
       SUM(profit) AS total_profit
FROM products p 
JOIN orders o ON p.product_id=o.product_id
GROUP BY p.category, o.product_id
)
SELECT * 
FROM(
SELECT *, 
       RANK() OVER(
       PARTITION BY category ORDER BY total_profit DESC
	   ) AS rnk
       FROM top_products
) t
WHERE rnk <= 2;

--3. Calculate the running total of sales over time (order date wise).

WITH running_total AS (
SELECT order_date, SUM(sales) AS total_Sales
FROM orders
GROUP BY order_date
)
SELECT *, 
         SUM(total_sales) 
		 OVER(ORDER BY order_date ASC) AS runn_total
FROM running_total;

--4. Find month-over-month (MoM) sales growth for the business.

WITH monthly_sales AS(

SELECT 
       DATE_TRUNC ('month', order_date) AS month,
       SUM(sales) AS total_sales
FROM orders
GROUP BY month
ORDER BY month
)
SELECT month, total_sales, 
       LAG(total_sales) OVER(ORDER BY month) AS prev_sales,
	   total_sales -  LAG(total_sales) OVER(ORDER BY month) AS growth_sales
FROM monthly_sales;

--5. Identify products that have high sales but low or negative profit.

SELECT product_id, SUM(sales) AS total_Sales, 
       SUM(profit) AS total_profit
FROM orders
GROUP BY product_id
HAVING SUM(profit) < 0
ORDER BY total_sales DESC;

--6. Find customers whose total sales are higher than the average sales of their respective region.

WITH customer_sales AS (
SELECT c.customer_id, c.region, SUM(sales) AS total_Sales
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.region  
), 
with_avg AS (
SELECT *,
        AVG(total_sales) OVER(PARTITION BY region) AS avg_region
FROM customer_sales
) 
SELECT * FROM with_avg
WHERE total_sales > avg_region;

--7. Identify months where sales declined compared to the previous month.

WITH decline_sales AS (
SELECT 
      DATE_TRUNC ('MONTH' , order_date) AS month,
	  SUM(sales) AS total_sales
	  FROM orders
	  GROUP BY month
)
SELECT month, total_sales, 
       LAG(total_sales) OVER(ORDER BY month) AS prev_sales,
	   total_sales - LAG(total_sales) OVER(ORDER BY month) AS growth_sales
FROM decline_sales;

--8. Calculate the profit contribution (%) of each product category to total profit.

WITH cal_profit AS 
(
SELECT p.category, SUM(o.profit) AS total_profit
FROM products p 
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.category
)
SELECT *, 
       SUM(total_profit) OVER() AS total_company_profit,
       (total_profit * 100.0 / SUM(total_profit) OVER()) AS contribution_percent
FROM cal_profit;

--9. Identify which region and category combination has the highest number of high-risk orders.

WITH high_risk_orders AS (
SELECT c.region, p.category, COUNT(*) AS count_orders
FROM customers c JOIN orders o 
ON c.customer_id = o.customer_id
JOIN products p 
ON p.product_id = o.product_id
WHERE o.risk_level = 'High Risk'
GROUP BY c.region, p.category
)
SELECT * FROM high_risk_orders
ORDER BY count_orders DESC
LIMIT 1;

--10. Perform Pareto analysis: Identify the top 20% products contributing to 80% of total sales.

WITH product_sales AS (
SELECT product_id, SUM(sales) AS total_sales
FROM orders
GROUP BY product_id
),
ranked AS (
SELECT *,
        SUM(total_sales) OVER(ORDER BY total_sales DESC) AS running_total,
		SUM(total_sales) OVER () AS total_company_sales
FROM product_sales
)
SELECT *,
        running_total * 100.0 / total_company_sales AS cumulative_percent
FROM ranked
WHERE running_total * 100.0 / total_company_sales <= 80;