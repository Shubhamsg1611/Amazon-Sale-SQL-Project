-- Amazon Sales Analysis Projects 

-- Create the table so we can import the data

CREATE TABLE sales(
					id int PRIMARY KEY,
					order_date date,
					customer_name VARCHAR(25),
					state VARCHAR(25),
					category VARCHAR(25),
					sub_category VARCHAR(25),
					product_name VARCHAR(255),
					sales FLOAT,
					quantity INT,
					profit FLOAT
					);
-- Importing the data into the table 

-- Exploratory Data Analysis and Pre Processing

--  Checking total rows count

SELECT * FROM sales;
SELECT COUNT(*)FROM sales;

-- Checking if there any missing values

SELECT COUNT(*)
FROM sales
WHERE id IS NULL 
   OR order_date IS NULL 
   OR customer_name IS NULL 
   OR state IS NULL 
   OR category IS NULL 
   OR sub_category IS NULL 
   OR product_name IS NULL 
   OR sales IS NULL 
   OR quantity IS NULL 
   OR profit IS NULL;

--  Checking for duplicate entry

SELECT * FROM 
	(SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn FROM sales ) x
WHERE rn > 1;

-- Feature Engineering 

--  creating a year column
ALTER TABLE sales
ADD COLUMN YEAR VARCHAR(4);
-- adding year value into the year column
UPDATE sales
SET year = EXTRACT(YEAR FROM order_date);

-- creating a new column for the month 
ALTER TABLE sales
ADD COLUMN MONTH VARCHAR(15);

-- adding abbreviated month name  
UPDATE sales
SET month = TO_CHAR(order_date, 'mon');

-- adding new column as day_name
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(15);

-- updating day name into the day column
UPDATE sales 
SET day_name = TO_CHAR(order_date, 'day');

SELECT TO_CHAR(order_date, 'day')
FROM sales;

-- Solving Business Problems 

--Q1. Find total sales for each category.

Select Category, Sum(Sales) as Total_Sales 
From Sales
Group by 1
Order by 2 desc

--Q2. Find out the top 5 customers who made the highest profits.

SELECT Customer_name, ROUND(CAST(SUM(Profit) AS NUMERIC), 2) AS Total_Profit
FROM Sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--Q3. Find out the average quantity ordered per category.

SELECT Category, ROUND(AVG(Quantity),2) AS Avg_Quantity
FROM Sales
GROUP BY 1
ORDER BY 2 DESC;

-- Q4. Identify the top 5 products that have generated the highest revenue.

Select Product_name as Product, ROUND(Cast(Sum(Sales) as Numeric) ,2) as Total_Revenue
From Sales
Group by 1
Order by 2 Desc
limit 5

-- Q5. Determine the top 5 products whose revenue has decreased compared to the previous year.

WITH R1 AS (
    SELECT Product_name AS Product, SUM(Sales) AS Total_Revenue
    FROM Sales
    WHERE CAST(Year AS INTEGER) = 2024
    GROUP BY 1
), 
R2 AS (
    SELECT Product_name AS Product, SUM(Sales) AS Total_Revenue
    FROM Sales
    WHERE CAST(Year AS INTEGER) = 2023
    GROUP BY 1
)

SELECT 
    R1.Product AS Product_name, 
    R1.Total_Revenue AS CurrentYear_Revenue, 
    R2.Total_Revenue AS PreviousYear_Revenue,
    ROUND(CAST(R1.Total_Revenue / R2.Total_Revenue AS NUMERIC), 2) AS Revenue_Decreased_Ratio
FROM 
    R1 
JOIN 
    R2 ON R1.Product = R2.Product
WHERE 
    R1.Total_Revenue < R2.Total_Revenue
ORDER BY 
    CurrentYear_Revenue DESC
LIMIT 5;

-- Q6. Identify the highest profitable sub-category.


SELECT 
    Sub_Category, 
    ROUND(CAST(SUM(Profit) AS NUMERIC), 2) AS Total_Profit
FROM 
    Sales
GROUP BY 
    Sub_Category
ORDER BY 
    Total_Profit DESC
LIMIT 1;

--Q7. Find out the top 10 states with the highest total orders.

Select State, ROUND(Sum(Quantity)) AS Total_Orders
From Sales
Group by 1
Order by 2
Limit 10

--Q8. Determine the month with the highest number of orders.

SELECT 
	(month ||'-' || year) month_name, -- for mysql CONCAT()
	COUNT(id)
FROM sales
GROUP BY 1
ORDER BY 2 DESC


-- Q9.Calculate the profit margin percentage for each sale (Profit divided by Category).

SELECT 
    Category, 
    ROUND(CAST((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100 AS NUMERIC), 2) AS Profit_Margin
FROM 
    Sales
GROUP BY 
    Category;

-- Q10.10 Calculate the percentage contribution of each sub-category to the total sales amount for the year 2024.

WITH CTE
	AS (SELECT
			sub_category,
			SUM(sales) as revenue_per_category
		FROM sales
		WHERE year = '2024'
		GROUP BY 1

)
SELECT	
	sub_category,
	(revenue_per_category / total_sales * 100)
FROM cte
CROSS JOIN
(SELECT SUM(sales) AS total_sales FROM sales WHERE year = '2024') AS cte1;

-- End of Project -- 			