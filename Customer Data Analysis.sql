
-- ============================================================
-- SECTION 0: DATABASE & TABLE CREATION (SCHEMA DESIGN)
-- ============================================================
CREATE DATABASE data_analysis;
GO
drop database data_analysis
USE data_analysis;
GO

IF NOT EXISTS (
    SELECT * FROM sys.tables 
    WHERE name = 'data'
)
BEGIN
    CREATE TABLE data (
        Customer_ID      INT PRIMARY KEY,
        Name             VARCHAR(50),
        Age              INT,
        Gender           VARCHAR(10),
        City             VARCHAR(50),
        Purchase_Amount  DECIMAL(10,2),
        Order_Count      INT
    );
END;

-- ============================================================
-- SECTION 1: DATA CLEANING
-- ============================================================

-- 1a. Check for NULL values
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Name IS NULL THEN 1 ELSE 0 END) AS Null_Name,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Null_Age,
    SUM(CASE WHEN Purchase_Amount IS NULL THEN 1 ELSE 0 END) AS Null_Purchase,
    SUM(CASE WHEN Order_Count IS NULL THEN 1 ELSE 0 END) AS Null_Orders
FROM data;

-- 1b. Find duplicates
SELECT Customer_ID, COUNT(*)
FROM data
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

-- 1c. Remove duplicates
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY Customer_ID) AS rn
    FROM data
)
DELETE FROM cte WHERE rn > 1;

-- ============================================================
-- SECTION 2: CUSTOMER SEGMENTATION
-- ============================================================
SELECT
    Customer_ID,
    Name,
    Purchase_Amount,
    Order_Count,
    CASE
        WHEN Purchase_Amount >= 2500 THEN 'High Value'
        WHEN Purchase_Amount >= 1500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment

FROM data
ORDER BY Purchase_Amount DESC;

-- ============================================================
-- SECTION 3: TOP CUSTOMERS
-- ============================================================
SELECT TOP 10
    Name,
    Purchase_Amount,
    Order_Count
FROM data
ORDER BY Purchase_Amount DESC;

-- ============================================================
-- SECTION 4: CITY-WISE ANALYSIS
-- ============================================================
SELECT
    City,
    COUNT(*) AS Total_Customers,
    SUM(Purchase_Amount) AS Total_Revenue,
    AVG(Purchase_Amount) AS Avg_Spending
FROM data
GROUP BY City
ORDER BY Total_Revenue DESC;

-- ============================================================
-- SECTION 5: REPEAT vs NEW CUSTOMERS
-- ============================================================
SELECT
    CASE
        WHEN Order_Count = 1 THEN 'New Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type,
    COUNT(*) AS Total_Customers
FROM data
GROUP BY
    CASE
        WHEN Order_Count = 1 THEN 'New Customer'
        ELSE 'Repeat Customer'
    END;

-- ============================================================
-- SECTION 6: AVERAGE ORDER VALUE (AOV)
-- ============================================================
SELECT
    Name,
    Purchase_Amount,
    Order_Count,
    ROUND(Purchase_Amount / NULLIF(Order_Count, 0), 2) AS Avg_Order_Value
FROM data;

-- ============================================================
-- SECTION 7: GENDER ANALYSIS
-- ============================================================
SELECT
    Gender,
    COUNT(*) AS Total_Customers,
    SUM(Purchase_Amount) AS Total_Revenue,
    AVG(Purchase_Amount) AS Avg_Spending
FROM data
GROUP BY Gender;

-- ============================================================
-- SECTION 8: TOP REPEAT CUSTOMERS
-- ============================================================
SELECT TOP 10
    Name,
    Order_Count,
    Purchase_Amount
FROM data
ORDER BY Order_Count DESC;

-- ============================================================
-- SECTION 9: CUSTOMER INSIGHT (COMBINED)
-- ============================================================
SELECT
    Name,
    City,
    Purchase_Amount,
    Order_Count,
    (Purchase_Amount * Order_Count) AS Engagement_Score
FROM data
ORDER BY Engagement_Score DESC;