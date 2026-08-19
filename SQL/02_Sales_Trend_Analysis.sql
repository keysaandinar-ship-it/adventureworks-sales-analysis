-- ============================================
-- 02 - Sales Trend Analysis
-- ============================================

-- Analysis 1: Revenue per Year
SELECT strftime('%Y', s.OrderDate) AS Year, SUM(p.ProductPrice*s.OrderQuantity) AS Revenue
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
ON s.ProductKey=p.ProductKey
GROUP BY Year
ORDER BY Year;

-- Analysis 2: Year-over-Year Revenue Growth
WITH SalesAll AS (
	SELECT strftime('%Y', s.OrderDate) AS Year, SUM(p.ProductPrice*s.OrderQuantity) AS Revenue
	FROM Sales AS s
	JOIN AdventureWorks_Product_Lookup AS p
	ON s.ProductKey=p.ProductKey
	GROUP BY Year
	ORDER BY Year)
SELECT Year, Revenue, ROUND((Revenue-LAG(Revenue) OVER (ORDER BY Year))*100.0/LAG(Revenue) OVER (ORDER BY Year),2) AS GrowthRevenue
FROM SalesAll;

-- Analysis 3: Year-over-Year Comparison
-- Comparing January-June 2021 vs January-June 2022
WITH Sales06 AS (
SELECT strftime('%Y', s.OrderDate) AS Year, SUM(p.ProductPrice*s.OrderQuantity) AS Revenue
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
ON s.ProductKey=p.ProductKey
WHERE strftime('%m', s.OrderDate) BETWEEN '01' AND '06'
GROUP BY Year
ORDER BY Year)
SELECT Year, Revenue, ROUND((Revenue-Lag(Revenue) OVER (ORDER BY Year))*100.0/LAG(Revenue) OVER (ORDER BY Year),2) AS Growth
FROM Sales06;

-- Analysis 4: Unit Sold Growth
WITH UnitSOld06 AS (
SELECT strftime('%Y', OrderDate) AS Year, SUM(OrderQuantity) AS UnitSold
FROM Sales
WHERE strftime('%m', OrderDate) BETWEEN '01' AND '06'
GROUP BY Year
ORDER BY Year)
SELECT Year, UnitSold, ROUND((UnitSold-Lag(UnitSold) OVER (ORDER BY Year))*100.0/LAG(UnitSold) OVER (ORDER BY Year),2) AS Growth
FROM UnitSold06;

-- Analysis 5: Category Performance 01-06
SELECT strftime('%Y', s.OrderDate) AS Year, c.CategoryName,  SUM(p.ProductPrice*s.OrderQuantity) AS Revenue, SUM(s.OrderQuantity) AS UnitSold
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
ON s.ProductKey=p.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS sc
ON sc.ProductSubcategoryKey=p.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS c
ON sc.ProductCategoryKey=c.ProductCategoryKey
WHERE strftime('%m', s.OrderDate) BETWEEN '01' AND '06'
GROUP BY Year, c.CategoryName
ORDER BY Year;

-- Analysis 5: Category Performance 01-06
SELECT strftime('%Y', s.OrderDate) AS Year, c.CategoryName,  SUM(p.ProductPrice*s.OrderQuantity) AS Revenue, SUM(s.OrderQuantity) AS UnitSold
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
ON s.ProductKey=p.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS sc
ON sc.ProductSubcategoryKey=p.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS c
ON sc.ProductCategoryKey=c.ProductCategoryKey
GROUP BY Year, c.CategoryName
ORDER BY Year;

-- Analysis 6: Revenue per Unit by Category
SELECT c.CategoryName,  SUM(p.ProductPrice*s.OrderQuantity) AS Revenue, SUM(s.OrderQuantity) AS UnitSold, ROUND(SUM(p.ProductPrice*s.OrderQuantity)/SUM(s.OrderQuantity),2) AS RevenuePerUnit
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
ON s.ProductKey=p.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS sc
ON sc.ProductSubcategoryKey=p.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS c
ON sc.ProductCategoryKey=c.ProductCategoryKey
GROUP BY c.CategoryName;

-- Analysis 7: Top 10 Customers by Revenue
SELECT c.CustomerKey, c.FirstName, c.LastName, SUM(p.ProductPrice*s.OrderQuantity) AS Revenue, SUM(s.OrderQuantity) AS UnitSold
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
ON p.ProductKey=s.ProductKey
JOIN AdventureWorks_Customer_Lookup AS c
ON s.CustomerKey=c.CustomerKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY Revenue DESC
LIMIT 10;

-- Analysis 8: Top 10 Customer Revenue Contribution
WITH RevenueTotal AS (
	SELECT SUM(p.ProductPrice*s.OrderQuantity) AS TotalRevenue
		FROM Sales AS s
		JOIN AdventureWorks_Product_Lookup AS p
		ON p.ProductKey=s.ProductKey),
TopCustomer AS (
	SELECT c.CustomerKey, c.FirstName, c.LastName, SUM(p.ProductPrice*s.OrderQuantity) AS Revenue
		FROM Sales AS s
		JOIN AdventureWorks_Product_Lookup AS p
		ON p.ProductKey=s.ProductKey
		JOIN AdventureWorks_Customer_Lookup AS c
		ON s.CustomerKey=c.CustomerKey
		GROUP BY c.CustomerKey, c.FirstName, c.LastName
		ORDER BY Revenue DESC
		LIMIT 10)
SELECT t.CustomerKey, t.FirstName, t.LastName, t.Revenue, ROUND(t.Revenue*100.0/r.TotalRevenue,4) AS Contribution
	FROM TopCustomer AS t
	CROSS JOIN RevenueTotal AS r;
	
-- Analysis 8b: Total Top 10 Customer Revenue Contribution
WITH RevenueTotal AS (
	SELECT SUM(p.ProductPrice*s.OrderQuantity) AS TotalRevenue
		FROM Sales AS s
		JOIN AdventureWorks_Product_Lookup AS p
		ON p.ProductKey=s.ProductKey),
TopCustomer AS (
	SELECT c.CustomerKey, c.FirstName, c.LastName, SUM(p.ProductPrice*s.OrderQuantity) AS Revenue
		FROM Sales AS s
		JOIN AdventureWorks_Product_Lookup AS p
		ON p.ProductKey=s.ProductKey
		JOIN AdventureWorks_Customer_Lookup AS c
		ON s.CustomerKey=c.CustomerKey
		GROUP BY c.CustomerKey, c.FirstName, c.LastName
		ORDER BY Revenue DESC
		LIMIT 10)
SELECT SUM(t.Revenue)AS RevenueTop10, ROUND(SUM(t.Revenue)*100.0/r.TotalRevenue,4) AS Contribution
	FROM TopCustomer AS t
	CROSS JOIN RevenueTotal AS r;
	
-- Analysis 9: Customer First Purchase Year
WITH FIRSTYEARBUY AS (
	SELECT C.CustomerKey,C.FirstName, C.LastName, MIN(strftime('%Y',S.OrderDate)) AS FIRSTYEAR
	FROM AdventureWorks_Customer_Lookup AS C
	JOIN SALES AS S
	ON C.CustomerKey=S.CustomerKey
	GROUP BY C.CustomerKey)
SELECT FIRSTYEAR, COUNT(FIRSTYEAR) AS NEWCUSTOMER
	FROM FIRSTYEARBUY
	GROUP BY FIRSTYEAR;

-- Analysis 10: New vs Returning Customers
WITH TOTALCUST AS (
SELECT strftime('%Y',OrderDate) AS YEAR, COUNT(DISTINCT CustomerKey) AS TOTALCUSTOMER
FROM Sales
GROUP BY strftime('%Y',OrderDate)),
FIRSTPURCHASE AS (
	SELECT CustomerKey, MIN(strftime('%Y',OrderDate)) AS FIRSTBUY
	FROM SALES
	GROUP BY CustomerKey)
SELECT T.YEAR, T.TOTALCUSTOMER, COUNT(F.CustomerKey) AS NEWCUSTOMER, T.TOTALCUSTOMER-COUNT(F.CustomerKey) AS RETURNINGCUSTOMER
	FROM TOTALCUST AS T
	LEFT JOIN FIRSTPURCHASE AS F
	ON F.FIRSTBUY=T.YEAR
	GROUP BY T.YEAR;
	
-- Analysis 11: Customer Retention 2021 to 2022
WITH RETAINEDCUST2022 AS (
	SELECT CustomerKey FROM AdventureWorks_Sales_Data_2021
		INTERSECT SELECT CustomerKey FROM AdventureWorks_Sales_Data_2022),
TOTALCUST2021 AS (
	SELECT COUNT(DISTINCT CustomerKey) AS "TOTAL CUST 2021"
	FROM AdventureWorks_Sales_Data_2021)
SELECT (SELECT "TOTAL CUST 2021" FROM TOTALCUST2021) AS "TOTAL CUST 2021",
	(SELECT COUNT(*) FROM RETAINEDCUST2022) AS "RETAINED CUSTOMER", 
	ROUND((SELECT COUNT(*) FROM RETAINEDCUST2022)*100.0/(SELECT "TOTAL CUST 2021" FROM TOTALCUST2021),2) AS "RETAINED RATE";
	
-- Analysis 12: Customer Value by Product Category
SELECT C.CategoryName, COUNT(S.CustomerKey) AS "TOTAL CUSTOMER", SUM(S.OrderQuantity) AS "UNIT SOLD", SUM(S.OrderQuantity*P.ProductPrice) 