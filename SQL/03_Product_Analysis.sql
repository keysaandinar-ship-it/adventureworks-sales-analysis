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

-- Analysis 14A: Top 10 Products by Revenue
SELECT P.ProductName, C.CategoryName, SUM(S.OrderQuantity*P.ProductPrice) AS REVENUE
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
ON P.ProductKey=S.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
ON P.ProductSubcategoryKey=SC.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS C
ON SC.ProductCategoryKey=C.ProductCategoryKey
GROUP BY P.ProductKey
ORDER BY REVENUE DESC
LIMIT 10;

-- Analysis 14B: Top 10 Products Revenue Contribution
WITH PRODUCTREVENUE AS (
SELECT P.ProductName, C.CategoryName, SUM(S.OrderQuantity*P.ProductPrice) AS REVENUE
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
ON P.ProductKey=S.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
ON P.ProductSubcategoryKey=SC.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS C
ON SC.ProductCategoryKey=C.ProductCategoryKey
GROUP BY P.ProductKey),
TOTALREVENUE AS (
SELECT SUM(S.OrderQuantity*P.ProductPrice) AS TOTALREVENUE
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
ON P.ProductKey=S.ProductKey)
SELECT P.ProductName, P.CategoryName, P.REVENUE, ROUND(P.REVENUE*100.0/T.TOTALREVENUE,2) AS "REVENUE CONTRIBUTION"
FROM PRODUCTREVENUE AS P
CROSS JOIN TOTALREVENUE AS T
ORDER BY REVENUE DESC
LIMIT 10;

-- Analysis 15: Mountain-200 Revenue Contribution
WITH PRODUCTREVENUE AS (
SELECT P.ProductKey, P.ProductName, C.CategoryName, SUM(S.OrderQuantity*P.ProductPrice) AS REVENUE
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
ON P.ProductKey=S.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
ON P.ProductSubcategoryKey=SC.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS C
ON SC.ProductCategoryKey=C.ProductCategoryKey
GROUP BY P.ProductKey),
TOTALREVENUE AS (
SELECT SUM(REVENUE) AS TOTALREVENUE
FROM PRODUCTREVENUE),
MOUNTAIN200REVENUE AS (
SELECT SUM(REVENUE) AS MOUNTAIN200REVENUE
FROM PRODUCTREVENUE
WHERE ProductName LIKE 'Mountain-200%')
SELECT M.MOUNTAIN200REVENUE, ROUND(M.MOUNTAIN200REVENUE*100.0/T.TOTALREVENUE,2) AS "REVENUE CONTRIBUTION"
FROM MOUNTAIN200REVENUE AS M
CROSS JOIN TOTALREVENUE AS T;

-- Analysis 16: Product Return Performance
WITH UNITSOLD AS (
	SELECT P.ProductKey, P.ProductName,C.CategoryName, SUM(S.OrderQuantity) AS "UNIT SOLD"
		FROM Sales AS S
		JOIN AdventureWorks_Product_Lookup AS P
		ON P.ProductKey=S.ProductKey
		JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
		ON P.ProductSubcategoryKey=SC.ProductSubcategoryKey
		JOIN AdventureWorks_Product_Categories_Lookup AS C
		ON SC.ProductCategoryKey=C.ProductCategoryKey
		GROUP BY P.ProductKey),
RETURN AS (
	SELECT P.ProductKey, P.ProductName, SUM(R.ReturnQuantity) AS "RETURN QTY"
		FROM AdventureWorks_Product_Lookup AS P
		LEFT JOIN AdventureWorks_Returns_Data AS R
		ON P.ProductKey=R.ProductKey
		GROUP BY P.ProductKey)
SELECT U.ProductName, U.CategoryName, U."UNIT SOLD", R."RETURN QTY", ROUND(R."RETURN QTY"*100.0/U."UNIT SOLD", 2) AS "RETURN RATE"
	FROM UNITSOLD AS U
	LEFT JOIN RETURN AS R
	ON U.ProductKey=R.ProductKey
	WHERE U."UNIT SOLD">100
	GROUP BY U.ProductKey
	ORDER BY "RETURN RATE" DESC;

-- Analysis 17: High Revenue vs Return Rate

WITH PRODUCTPERFORMANCE AS (
    SELECT
        P.ProductKey,
        P.ProductName,
        C.CategoryName,
        SUM(S.OrderQuantity) AS "UNIT SOLD",
        SUM(S.OrderQuantity * P.ProductPrice) AS REVENUE
    FROM Sales AS S
    JOIN AdventureWorks_Product_Lookup AS P
        ON P.ProductKey = S.ProductKey
    JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
        ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
    JOIN AdventureWorks_Product_Categories_Lookup AS C
        ON SC.ProductCategoryKey = C.ProductCategoryKey
    GROUP BY
        P.ProductKey,
        P.ProductName,
        C.CategoryName
),

PRODUCTRETURN AS (
    SELECT
        ProductKey,
        SUM(ReturnQuantity) AS "RETURN QTY"
    FROM AdventureWorks_Returns_Data
    GROUP BY ProductKey
)

SELECT
    PP.ProductName,
    PP.CategoryName,
    ROUND(PP.REVENUE, 2) AS REVENUE,
    PP."UNIT SOLD",
    COALESCE(PR."RETURN QTY", 0) AS "RETURN QTY",
    ROUND(
        COALESCE(PR."RETURN QTY", 0) * 100.0
        / PP."UNIT SOLD",
        2
    ) AS "RETURN RATE"
FROM PRODUCTPERFORMANCE AS PP
LEFT JOIN PRODUCTRETURN AS PR
    ON PP.ProductKey = PR.ProductKey
WHERE PP."UNIT SOLD" > 100
ORDER BY PP.REVENUE DESC
LIMIT 20;

-- ANALISIS PROOFIT PER KATEGORI
WITH PROFIT_KATEGORI AS (
	SELECT C.CategoryName, SUM(S.OrderQuantity*(P.ProductPrice-P.ProductCost)) AS PROFIT
	FROM Sales AS S
	JOIN AdventureWorks_Product_Lookup AS P
	ON P.ProductKey=S.ProductKey
	JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
	ON SC.ProductSubcategoryKey=P.ProductSubcategoryKey
	JOIN AdventureWorks_Product_Categories_Lookup AS C
	ON SC.ProductCategoryKey=C.ProductCategoryKey
	GROUP BY C.ProductCategoryKey),
TOTAL_PROFIT AS (
	SELECT SUM(S.OrderQuantity*(P.ProductPrice-P.ProductCost)) AS TOTAL_PROFIT
	FROM Sales AS S
	JOIN AdventureWorks_Product_Lookup AS P
	ON P.ProductKey=S.ProductKey)
SELECT P.CategoryName AS KATEGORI, P.PROFIT, ROUND(P.PROFIT*100.0/T.TOTAL_PROFIT, 2) AS KONTRIBUSI
	FROM PROFIT_KATEGORI AS P
	CROSS JOIN TOTAL_PROFIT AS T;
	
-- ANALYSIS: PROFIT MARGIN PER KATEGORI

SELECT
    C.CategoryName AS KATEGORI,
    SUM(
        S.OrderQuantity * (P.ProductPrice - P.ProductCost)
    ) AS PROFIT,
    SUM(
        S.OrderQuantity * P.ProductPrice
    ) AS REVENUE,
    ROUND(
        SUM(
            S.OrderQuantity * (P.ProductPrice - P.ProductCost)
        ) * 100.0
        / SUM(
            S.OrderQuantity * P.ProductPrice
        ),
        2
    ) AS MARGIN
FROM Sales AS S
JOIN AdventureWorks_Product_Lookup AS P
    ON P.ProductKey = S.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS SC
    ON SC.ProductSubcategoryKey = P.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS C
    ON SC.ProductCategoryKey = C.ProductCategoryKey
GROUP BY C.CategoryName
ORDER BY MARGIN DESC;

--ANALISIS TOP 10 PRODUK BERDASARKAN KONTRIBUSI TERHADAP PROFIT
WITH PROFIT_PRODUK AS (
SELECT P.ProductName, SUM(S.OrderQuantity*(P.ProductPrice-P.ProductCost)) AS PROFIT
	FROM Sales AS S
	JOIN AdventureWorks_Product_Lookup AS P
	ON P.ProductKey=S.ProductKey
	GROUP BY P.ProductKey),
TOTAL_PROFIT AS (
SELECT SUM(S.OrderQuantity*(P.ProductPrice-P.ProductCost)) AS TOTAL_PROFIT
	FROM Sales AS S
	JOIN AdventureWorks_Product_Lookup AS P
	ON P.ProductKey=S.ProductKey)
SELECT P.ProductName, P.PROFIT, ROUND(P.PROFIT*100.0/T.TOTAL_PROFIT,2) AS KONTRIBUSI
	FROM PROFIT_PRODUK AS P
	CROSS JOIN TOTAL_PROFIT AS T
	GROUP BY P.ProductName
	ORDER BY PROFIT DESC
	LIMIT 10;
	
SELECT 
    p1.ProductName AS Product_A,
    p2.ProductName AS Product_B,
    COUNT(*) AS BoughtTogetherCount
FROM Sales AS s1
JOIN Sales AS s2 
    ON s1.OrderNumber = s2.OrderNumber 
    AND s1.ProductKey < s2.ProductKey
JOIN AdventureWorks_Product_Lookup AS p1 ON s1.ProductKey = p1.ProductKey
JOIN AdventureWorks_Product_Lookup AS p2 ON s2.ProductKey = p2.ProductKey
GROUP BY Product_A, Product_B
ORDER BY BoughtTogetherCount DESC
LIMIT 10;

SELECT 
    c.CategoryName,
    SUM(r.ReturnQuantity) AS TotalReturnedUnits,
    SUM(r.ReturnQuantity * p.ProductPrice) AS EstimatedLostRevenue,
    SUM(r.ReturnQuantity * (p.ProductPrice - p.ProductCost)) AS EstimatedLostProfit
FROM AdventureWorks_Returns_Data AS r
JOIN AdventureWorks_Product_Lookup AS p ON r.ProductKey = p.ProductKey
JOIN AdventureWorks_Product_Subcategories_Lookup AS sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN AdventureWorks_Product_Categories_Lookup AS c ON sc.ProductCategoryKey = c.ProductCategoryKey
GROUP BY c.CategoryName
ORDER BY EstimatedLostProfit DESC;
