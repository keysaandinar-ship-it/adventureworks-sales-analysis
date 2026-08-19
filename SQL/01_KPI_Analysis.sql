-- ============================================
-- AdventureWorks Sales Performance Analysis
-- 01 - KPI Analysis
-- ============================================

-- KPI 1: Total Revenue
SELECT 
    SUM(s.OrderQuantity * p.ProductPrice) AS TotalRevenue
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
    ON s.ProductKey = p.ProductKey;
	
-- KPI 2: Total Orders
SELECT 
    COUNT(DISTINCT s.OrderNumber) AS TotalOrders
FROM Sales AS s;

-- KPI 3: Total Customers
SELECT 
    COUNT(DISTINCT s.CustomerKey) AS TotalCustomers
FROM Sales AS s;

-- KPI 4: Total Units Sold
SELECT 
    SUM(s.OrderQuantity) AS TotalUnitsSold
FROM Sales AS s;

-- KPI 5: Average Order Value
SELECT 
    ROUND(SUM(s.OrderQuantity * p.ProductPrice) / COUNT(DISTINCT s.OrderNumber),2) AS AverageOrderValue
FROM Sales AS s
JOIN AdventureWorks_Product_Lookup AS p
    ON s.ProductKey = p.ProductKey;

-- KPI 6a: Total Returned Units
SELECT 
    SUM(r.ReturnQuantity) AS TotalReturnedUnits
FROM AdventureWorks_Returns_Data AS r;

-- KPI 6b: Return Rate
WITH SalesReturn AS (
SELECT SUM(ReturnQuantity) AS TotalUnitReturn
FROM AdventureWorks_Returns_Data),
SalesQuantity AS (
SELECT SUM(OrderQuantity) AS TotalUnitSold
FROM Sales)
SELECT ROUND(r.TotalUnitReturn*100.0/q.TotalUnitSold,2) AS ReturnRate
FROM SalesReturn AS r
CROSS JOIN SalesQuantity AS q;