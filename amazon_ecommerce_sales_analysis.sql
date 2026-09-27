CREATE TABLE amazon_sales (
  "index" INTEGER, 
  "Order ID" VARCHAR(50),
  "Date" DATE,
  "Status" VARCHAR(50),
  "Fulfilment" VARCHAR(50),
  "Sales Channel" VARCHAR(100),
  "ship-service-level" VARCHAR(50),
  "Style" VARCHAR(50),
  "SKU" VARCHAR(100),
  "Category" VARCHAR(100),
  "Size" VARCHAR(20),
  "ASIN" VARCHAR(50),
  "Couries Status" VARCHAR(50),
  "Qty" INTEGER,
  "currency" VARCHAR(10),
  "Amount" NUMERIC(12,2),
  "ship-city" VARCHAR(100),
  "ship-state" VARCHAR(100),
  "ship-postal-code" VARCHAR(20),
  "ship-country" VARCHAR(50),
  "promotion-ids" TEXT,
  "B2B" BOOLEAN,
  "fulfilled-by" VARCHAR(100)
  );

--Step 1: Total number of records
SELECT COUNT(*) AS total_records
FROM amazon_sales;

--Explanation: Counts the total number of records to validate the imported dataset.

--Step 2: Number of unique records
SELECT COUNT(DISTINCT "Order ID")
AS unique_records
FROM amazon_sales;

--Explanation: Calculates the total number of unique orders in the dataset.

--Step 3: Date range of orders
SELECT
   MIN("Date") AS
first_order_date,
   MAX("Date") AS last_order_date
FROM amazon_sales;   

--Explanation: Identifies the period covered by the e-commerce sales data.

--Step 4: Order Status distribution
SELECT
   "Status",
   COUNT(*) AS order_count
FROM amazon_sales
GROUP BY "Status"
ORDER BY order_count DESC;

--Explanation: Shows the distribution of orders across different order statuses.

--Step 5: Total sales revenue
SELECT
   ROUND(SUM("Amount")::numeric,2) AS total_sales
FROM amazon_sales
WHERE "Amount" IS NOT NULL;  

--Explanation: Calculates the total sales revenue generated from the available transactions.

--Step 6: Total quantity sold
SELECT
  SUM("Qty") AS total_quantity_sold
FROM amazon_sales
WHERE "Qty" IS NOT NULL;  

--Explanation: Calculates the total number of units sold across all transactions.

--Step 7: Average order value
SELECT
  ROUND(
     SUM("Amount")::numeric/
	 COUNT(DISTINCT "Order ID"),2) AS average_order_value
FROM amazon_sales
WHERE "Amount" IS NOT NULL;  

--Explanation: Calculates the average sales value generated per unique order.

--Step 8: Monthly Sales
SELECT
    DATE_TRUNC('month', "Date") AS
	month,
	ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales
FROM amazon_sales
WHERE "Amount" IS NOT NULL
GROUP BY DATE_TRUNC('month', "Date")
ORDER BY month;

--Explanation: Analyzes monthly sales trends to identify changes in revenue over time.

--Step 9: Monthly order volume
SELECT
    DATE_TRUNC('month', "Date") AS
	month,
	COUNT(DISTINCT "Order ID") AS total_orders
FROM amazon_sales
GROUP BY DATE_TRUNC('month', "Date")
ORDER BY month;

--Explanation: Tracks monthly order volume to understand changes in purchasing activity.

--Step 10: Yearly sales
SELECT
    EXTRACT(YEAR FROM "Date") AS
	year,
	ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales
FROM amazon_sales
GROUP BY EXTRACT(YEAR FROM "Date")
ORDER BY year;

--Explanation: Compares annual sales performance to identify changes in revenue across years.

--Step 11: Sales by category
SELECT
    "Caregory",
	ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales,
	 SUM("Qty") AS total_quantity
FROM amazon_sales
WHERE "Amount" IS NOT NULL
GROUP BY "Caregory"
ORDER BY total_sales DESC;

--Explanation: Identifies the product categories contributing the most to sales.

--Step 12: Top 10 styles by sales
SELECT
    "Style",
	ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales,
	 SUM("Qty") AS total_quantity
FROM amazon_sales
WHERE "Amount" IS NOT NULL
GROUP BY "Style"
ORDER BY total_sales DESC
LIMIT 10;

--Explanation: Identifies the top-performing product styles based on sales revenue.

--Step 13: Top 10 SKUs by quantity sold
SELECT
    "SKU",
  SUM("Qty") AS total_quantity
FROM amazon_sales
WHERE "Qty" IS NOT NULL
GROUP BY "SKU"
ORDER BY total_quantity DESC
LIMIT 10;

--Explanation: Identifies the highest-volume SKUs based on units sold.

--Step 14: Sales by product size
SELECT
    "Size",
	SUM("Qty") AS total_quantity,
	ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY "Size"
ORDER BY total_quantity DESC;

--Explanation: Analyzes product demand across different sizes.

--Step 15: Sales by state
SELECT
    "ship-state",
		ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales,
	 COUNT(DISTINCT "Order ID") AS total_orders
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY "ship-state"
ORDER BY total_sales DESC;

--Explanation: Identifies the states generating the highest sales and order volumes.

--Step 16: Top 10 cities by sales
SELECT
    "ship-city",
		ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales,
	 COUNT(DISTINCT "Order ID") AS total_orders
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY "ship-city"
ORDER BY total_sales DESC
LIMIT 10;

--Explanation: Identifies the cities contributing the most sales revenue.

--Step 17: Sales by fulfilment method
SELECT
    "Fulfilment",
	COUNT(DISTINCT "Order ID") AS total_orders,
		ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales,
	 COUNT(DISTINCT "Order ID") AS total_orders
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY "Fulfilment"
ORDER BY total_sales DESC;

--Explanation: Compares sales and order volumes across different fulfilment volumes.

--Step 18: Couries status analysis
SELECT
   "Couries Status",
   COUNT(*) AS order_count
FROM amazon_sales	 
GROUP BY "Couries Status"
ORDER BY order_count DESC;
   
--Explanation: Analyzes the distribution of orders across different couries statuses.

--Step 19: Shipping service-level analysis
SELECT
   "ship-service-level",
COUNT(DISTINCT "Order ID") AS total_orders,
ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY "ship-service-level"
ORDER BY total_orders DESC;   

--Explanation: Compares order volume and sales across different shipping service levls.

--Step 20: Cancelled orders
SELECT
   COUNT(DISTINCT "Order ID") AS cancelled_orders
FROM amazon_sales	 
WHERE "Status" ILIKE '%cancel%';

--Explanation: Calculates the number of unique orders that were cancelled.

--Step 21: Cancellation rate
WITH order_status AS (
    SELECT
	   "Order ID",
	    MAX(
             CASE
			     WHEN  "Status"
ILIKE '%cancel%' THEN 1
                 ELSE 0
				  END
				  ) AS cancelled
		FROM amazon_sales
		GROUP BY "Order ID"
)
SELECT
   ROUND(
       100.0 * SUM(cancelled) /
	   COUNT(*),2) AS cancellation_rate
FROM order_status;	   
   
--Explanation: Calculates the percentage of unique orders that were cancelled.

--Step 22: B2B vs non-B2B sales
SELECT
   "B2B",
COUNT(DISTINCT "Order ID") AS total_orders,
ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY "B2B"
ORDER BY total_sales DESC;   

--Explanation: Compares sales and order volumes between B2B and non-B2B transactions.

--Step 23: Promotion usage analysis
SELECT
   CASE
      WHEN "promotion-ids" IS
NULL
	         OR
TRIM("promotion-ids") = ''
     THEN 'No Promotion'
	 ELSE 'Promotion Used'
	END AS promotion_status,  
COUNT(DISTINCT "Order ID") AS total_orders,
ROUND(
     SUM("Amount")::numeric
	 ,2) AS total_sales
FROM amazon_sales	 
WHERE "Amount" IS NOT NULL
GROUP BY promotion_status
ORDER BY total_sales DESC;   
		
--Explanation: Compares order volume and sales between promotional and non-promotional transactions.

--Step 24: Rank states by sales
WITH state_sales AS (
  SELECT
    "ship-state" AS state,
	 SUM("Amount") AS
total_sales
   FROM amazon_sales
   WHERE "Amount" IS NOT NULL
GROUP BY "ship-state"
)
SELECT
  state,
ROUND(
     total_sales::numeric
	 ,2) AS total_sales,
	 RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM state_sales	 
ORDER BY sales_rank; 

--Explanation: Ranks states according to their total sales performance using a window function.

--Step 25: Top 3 states by sales
WITH state_sales AS (
  SELECT
    "ship-state" AS state,
	 SUM("Amount") AS
total_sales
   FROM amazon_sales
   WHERE "Amount" IS NOT NULL
GROUP BY "ship-state"
),
ranked_states AS (
   SELECT
      state,
	  total_sales,
	  DENSE_RANK() OVER(ORDER BY total_sales DESC) AS sales_rank
FROM state_sales
)
 SELECT
  state,
ROUND(
     total_sales::numeric
	 ,2) AS total_sales,
	   sales_rank
FROM ranked_states
WHERE sales_rank <= 3
ORDER BY sales_rank; 

--Explanation: Identifies the three highest-performing states based on total sales.

--Step 26: Category contribution to total sales
WITH category_sales AS (
  SELECT
    "Category" AS category,
	 SUM("Amount") AS
total_sales
   FROM amazon_sales
   WHERE "Amount" IS NOT NULL
GROUP BY "Category"
)
 SELECT
   category,
   ROUND(
     total_sales::numeric
	 ,2) AS total_sales,
	 ROUND(
	        100.0 * total_sales /
			SUM(total_sales) OVER(),2) AS sales_percentage
FROM category_sales
ORDER BY total_sales DESC;			
    
--Explanation: Calculates each product category's perecentage contribution to overall sales.

--Step 27: Monthly Category ranking
WITH monthly_category_sales AS (
  SELECT
    DATE_TRUNC('month', "Date") AS month,
    "Category" AS category,
	 SUM("Amount") AS
total_sales
   FROM amazon_sales
   WHERE "Amount" IS NOT NULL
GROUP BY 
  DATE_TRUNC('month', "Date"),
   "Category"
)
 SELECT
   month,
   category,
   ROUND(
     total_sales::numeric
	 ,2) AS total_sales,
	RANK() OVER (
	    PARTITION BY month
	    ORDER BY total_sales DESC
		) AS category_rank
FROM monthly_category_sales
ORDER BY month, category_rank;			
    
--Explanation: Ranks product categories within each month according to their sales performance.	

--Step 28: Top 10 products' contribution to sales
WITH product_sales AS (
  SELECT
    "Style" AS product,
	 SUM("Amount") AS
total_sales
   FROM amazon_sales
   WHERE "Amount" IS NOT NULL
GROUP BY "Style"
),
ranked_products AS (
   SELECT
      product,
	  total_sales,
	  RANK() OVER(ORDER BY total_sales DESC) AS product_rank
FROM product_sales
)
 SELECT
 product,
ROUND(
     total_sales::numeric
	 ,2) AS total_sales,
ROUND(
	        100.0 * total_sales /
			SUM(total_sales) OVER(),2) AS percentage_of_total_sales	 
  FROM ranked_products	  
WHERE product_rank <= 10
ORDER BY total_sales DESC;			
    
--Explanation: Measures the contribution of the top-selling products to overall sales.

--Step 29: Average order value by category
SELECT
    "Category",
	ROUND(
     AVG("Amount")::numeric
	 ,2) AS average_order_value,
	 COUNT(DISTINCT "Order ID") AS total_orders
FROM amazon_sales
WHERE "Amount" IS NOT NULL
GROUP BY "Category"
ORDER BY average_order_value DESC;

--Explanation: Compares average order values across different product categories.

--Step 30: Missing values in important columns
SELECT
  COUNT(*) FILTER(WHERE "Order ID" IS NULL) AS missing_order_id,
COUNT(*) FILTER(WHERE "Date" IS NULL) AS missing_date,
COUNT(*) FILTER(WHERE "Category" IS NULL) AS missing_category,
COUNT(*) FILTER(WHERE "Qty" IS NULL) AS missing_quantity,
COUNT(*) FILTER(WHERE "Amount" IS NULL) AS missing_amount,
COUNT(*) FILTER(WHERE "ship-state" IS NULL) AS missing_state
FROM amazon_sales;

--Explanation: Checks important fields for missing values to assess the quality of the dataset.







 