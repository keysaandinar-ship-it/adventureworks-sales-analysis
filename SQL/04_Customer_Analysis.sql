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
WITH CATEGORY AS(
SELECT C.CategoryName, 
	COUNT(DISTINCT S.CustomerKey) AS "TOTAL CUSTOMER", 
	SUM(S.OrderQuantity) AS "UNIT SOLD", 
	SUM(S.OrderQuantity*P.ProductPrice) AS REVENUE
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
ON P.ProductKey=S.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
ON P.ProductSubcategoryKey=SC.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS C
ON SC.ProductCategoryKey=C.ProductCategoryKey
GROUP BY C.CategoryName)
SELECT CategoryName, "TOTAL CUSTOMER", "UNIT SOLD", REVENUE, ROUND(REVENUE/"TOTAL CUSTOMER",2) AS "REVENUE PER CUSTOMER"
FROM CATEGORY; 

-- Analysis 13: Customer Cross-Category Purchase
WITH CustomerCategoryPurchase AS (
SELECT S.CustomerKey,
	MAX(CASE WHEN C.CategoryName='Bikes' THEN 1 ELSE 0 END) AS Bikes,
	MAX(CASE WHEN C.CategoryName='Accessories' THEN 1 ELSE 0 END) AS Accessories,
	MAX(CASE WHEN C.CategoryName='Clothing' THEN 1 ELSE 0 END) AS Clothing
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
ON P.ProductKey=S.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
ON P.ProductSubcategoryKey=SC.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS C
ON SC.ProductCategoryKey=C.ProductCategoryKey
GROUP BY S.CustomerKey)
SELECT CASE	
	WHEN Bikes=1 AND Accessories=1 AND Clothing=1
		THEN 'Bikes + Accessories + Clothing'
	WHEN Bikes=1 AND Accessories=1
		THEN 'Bikes + Accessories'
	WHEN Bikes=1 AND Clothing=1
		THEN 'Bikes + Clothing'
	WHEN Accessories=1 AND Clothing=1
		THEN 'Accessories + Clothing'
	ELSE 'Single Category'
END AS "CROSS PRODUCT",
COUNT(*) AS "TOTAL CUSTOMER"
FROM CustomerCategoryPurchase
GROUP BY "CROSS PRODUCT";

--ANALISIS GENERASI Customer
WITH TAHUNLAHIR AS (
SELECT CustomerKey, strftime('%Y', BirthDate) AS YEAR
FROM AdventureWorks_Customer_Lookup)
SELECT CustomerKey, 
CASE
	WHEN YEAR BETWEEN '1883' AND '1900' THEN 'LOST GENERATION'
	WHEN YEAR BETWEEN '1901' AND '1927' THEN 'GREATEST GENERATION'
	WHEN YEAR BETWEEN '1928' AND '1945' THEN 'SILENT GENERATION'
	WHEN YEAR BETWEEN '1946' AND '1964' THEN 'BABY BOOMERS'
	ELSE 'GENERASI X'
END AS GENERASI
FROM TAHUNLAHIR;

WITH CustomerSpending AS (
    SELECT 
        s.CustomerKey,
        SUM(s.OrderQuantity * p.ProductPrice) AS TotalSpend
    FROM Sales AS s
    JOIN AdventureWorks_Product_Lookup AS p ON s.ProductKey = p.ProductKey
    GROUP BY s.CustomerKey
)
SELECT 
    CASE 
        WHEN TotalSpend >= 5000 THEN 'High Spender (>= $5k)'
        WHEN TotalSpend BETWEEN 1000 AND 4999 THEN 'Medium Spender ($1k-$5k)'
        ELSE 'Low Spender (< $1k)'
    END AS SpendingTier,
    COUNT(CustomerKey) AS TotalCustomers,
    ROUND(SUM(TotalSpend), 2) AS CombinedRevenue
FROM CustomerSpending
GROUP BY SpendingTier
ORDER BY CombinedRevenue DESC;