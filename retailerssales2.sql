USE sales_db;

DROP TABLE IF EXISTS cleaned_data;

CREATE TABLE cleaned_data (
    Order_Number        INT,
    State_Code          VARCHAR(10),
    Customer_Name       VARCHAR(100),
    Order_Date          DATE,
    Status              VARCHAR(20),
    Product             VARCHAR(100),
    Category            VARCHAR(50),
    Brand               VARCHAR(50),
    Cost                DECIMAL(10, 2),
    Sales               DECIMAL(10, 2),
    Quantity            INT,
    Total_Cost          DECIMAL(12, 2),
    Total_Sales         DECIMAL(12, 2),
    Assigned_Supervisor VARCHAR(100)
);


-- ============================================
-- 2. BASIC EXPLORATION
-- ============================================

-- View all records
SELECT * FROM cleaned_data LIMIT 100;

-- Total number of orders
SELECT COUNT(*) AS Total_Orders FROM cleaned_data;

-- Orders by status
SELECT Status, COUNT(*) AS Order_Count
FROM cleaned_data
GROUP BY Status
ORDER BY Order_Count DESC;

-- Orders by category
SELECT Category, COUNT(*) AS Order_Count
FROM cleaned_data
GROUP BY Category
ORDER BY Order_Count DESC;


-- ============================================
-- 3. SALES ANALYSIS
-- ============================================

-- Total revenue and cost
SELECT 
    SUM(Total_Sales) AS Total_Revenue,
    SUM(Total_Cost)  AS Total_Cost,
    SUM(Total_Sales - Total_Cost) AS Total_Profit
FROM cleaned_data;

-- Revenue by category
SELECT 
    Category,
    SUM(Total_Sales)              AS Revenue,
    SUM(Total_Cost)               AS Cost,
    SUM(Total_Sales - Total_Cost) AS Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2) AS Profit_Margin_Pct
FROM cleaned_data
GROUP BY Category
ORDER BY Revenue DESC;

-- Revenue by brand
SELECT 
    Brand,
    SUM(Total_Sales) AS Revenue,
    SUM(Quantity)    AS Units_Sold
FROM cleaned_data
GROUP BY Brand
ORDER BY Revenue DESC;

-- Monthly sales trend
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
    SUM(Total_Sales)                 AS Monthly_Revenue,
    COUNT(*)                         AS Orders
FROM cleaned_data
GROUP BY Month
ORDER BY Month;


-- ============================================
-- 4. STATE / REGIONAL ANALYSIS
-- ============================================

-- Revenue by state
SELECT 
    State_Code,
    COUNT(*)         AS Orders,
    SUM(Total_Sales) AS Revenue
FROM cleaned_data
GROUP BY State_Code
ORDER BY Revenue DESC;


-- ============================================
-- 5. SUPERVISOR PERFORMANCE
-- ============================================

SELECT 
    Assigned_Supervisor,
    COUNT(*)                          AS Total_Orders,
    SUM(Total_Sales)                  AS Total_Revenue,
    ROUND(AVG(Total_Sales), 2)        AS Avg_Order_Value,
    SUM(Total_Sales - Total_Cost)     AS Total_Profit
FROM cleaned_data
GROUP BY Assigned_Supervisor
ORDER BY Total_Revenue DESC;


-- ============================================
-- 6. TOP PRODUCTS
-- ============================================

SELECT 
    Product,
    Category,
    SUM(Quantity)    AS Units_Sold,
    SUM(Total_Sales) AS Revenue
FROM cleaned_data
GROUP BY Product, Category
ORDER BY Revenue DESC
LIMIT 10;


-- ============================================
-- 7. DELIVERED ORDERS ONLY
-- ============================================

SELECT 
    Category,
    SUM(Total_Sales) AS Delivered_Revenue
FROM cleaned_data
WHERE Status = 'Delivered'
GROUP BY Category
ORDER BY Delivered_Revenue DESC;


-- ============================================
-- 8. HIGH-VALUE ORDERS (above average)
-- ============================================

SELECT *
FROM cleaned_data
WHERE Total_Sales > (SELECT AVG(Total_Sales) FROM cleaned_data)
ORDER BY Total_Sales DESC;


-- ============================================
-- 9. TOP CUSTOMERS QUERY
-- Returns customers ranked by total spending
-- ============================================

SELECT 
    Customer_Name,
    COUNT(*)                       AS Total_Orders,
    SUM(Total_Sales)               AS Total_Spent,
    ROUND(AVG(Total_Sales), 2)     AS Avg_Order_Value,
    SUM(Quantity)                  AS Total_Units_Bought,
    SUM(Total_Sales - Total_Cost)  AS Revenue_Generated
FROM cleaned_data
GROUP BY Customer_Name
ORDER BY Total_Spent DESC
LIMIT 20;


-- ============================================
-- 10. PROFIT BY BRAND
-- Ranks brands by profitability and margin
-- ============================================

SELECT 
    Brand,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Total_Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Profit_Margin_Pct,
    SUM(Quantity)                                                       AS Units_Sold
FROM cleaned_data
GROUP BY Brand
ORDER BY Total_Profit DESC;


-- ============================================
-- 11. LOW PERFORMING CATEGORIES
-- Categories with below-average revenue or
-- negative / thin profit margins
-- ============================================

SELECT 
    Category,
    SUM(Total_Sales)                                                    AS Revenue,
    SUM(Total_Cost)                                                     AS Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Profit_Margin_Pct,
    COUNT(*)                                                            AS Order_Count
FROM cleaned_data
GROUP BY Category
HAVING Revenue < (SELECT AVG(Category_Revenue)
                  FROM (SELECT SUM(Total_Sales) AS Category_Revenue
                        FROM cleaned_data
                        GROUP BY Category) AS sub)
ORDER BY Revenue ASC;


-- ============================================
-- 12. AVERAGE ORDER VALUE
-- Overall and broken down by key dimensions
-- ============================================

-- Overall AOV
SELECT 
    ROUND(AVG(Total_Sales), 2)    AS Avg_Order_Value,
    ROUND(AVG(Total_Cost), 2)     AS Avg_Order_Cost,
    ROUND(AVG(Quantity), 2)       AS Avg_Units_Per_Order
FROM cleaned_data;

-- AOV by Category
SELECT 
    Category,
    ROUND(AVG(Total_Sales), 2)    AS Avg_Order_Value,
    ROUND(AVG(Quantity), 2)       AS Avg_Units_Per_Order
FROM cleaned_data
GROUP BY Category
ORDER BY Avg_Order_Value DESC;

-- AOV by Brand
SELECT 
    Brand,
    ROUND(AVG(Total_Sales), 2)    AS Avg_Order_Value,
    ROUND(AVG(Quantity), 2)       AS Avg_Units_Per_Order
FROM cleaned_data
GROUP BY Brand
ORDER BY Avg_Order_Value DESC;


-- ============================================
-- 13. DASHBOARD QUERIES SECTION
-- Key KPI snapshot for a summary dashboard
-- ============================================

-- Overall KPIs
SELECT 
    COUNT(*)                                                            AS Total_Orders,
    COUNT(DISTINCT Customer_Name)                                       AS Unique_Customers,
    COUNT(DISTINCT Product)                                             AS Unique_Products,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Total_Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Overall_Profit_Margin_Pct,
    ROUND(AVG(Total_Sales), 2)                                          AS Avg_Order_Value,
    SUM(Quantity)                                                       AS Total_Units_Sold
FROM cleaned_data;

-- Orders by Status (for status breakdown widget)
SELECT 
    Status,
    COUNT(*)                                                            AS Order_Count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)                 AS Status_Pct,
    SUM(Total_Sales)                                                    AS Revenue
FROM cleaned_data
GROUP BY Status
ORDER BY Order_Count DESC;


-- ============================================
-- 14. TOP 5 PRODUCTS BY QUANTITY SOLD
-- ============================================

SELECT 
    Product,
    Category,
    Brand,
    SUM(Quantity)    AS Total_Units_Sold,
    SUM(Total_Sales) AS Total_Revenue
FROM cleaned_data
GROUP BY Product, Category, Brand
ORDER BY Total_Units_Sold DESC
LIMIT 5;


-- ============================================
-- 15. MONTHLY PROFIT TREND
-- Tracks profit growth/decline month over month
-- ============================================

SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m')              AS Month,
    SUM(Total_Sales)                              AS Monthly_Revenue,
    SUM(Total_Cost)                               AS Monthly_Cost,
    SUM(Total_Sales - Total_Cost)                 AS Monthly_Profit,
    ROUND(SUM(Total_Sales - Total_Cost)
          / SUM(Total_Sales) * 100, 2)            AS Profit_Margin_Pct,
    COUNT(*)                                      AS Total_Orders
FROM cleaned_data
GROUP BY Month
ORDER BY Month;


-- ============================================
-- 16. DELIVERED VS CANCELLED ORDERS ANALYSIS
-- Side-by-side comparison of key metrics
-- ============================================

SELECT 
    Status,
    COUNT(*)                                                            AS Order_Count,
    SUM(Quantity)                                                       AS Total_Units,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Total_Profit,
    ROUND(AVG(Total_Sales), 2)                                          AS Avg_Order_Value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)                 AS Status_Share_Pct
FROM cleaned_data
WHERE Status IN ('Delivered', 'Cancelled')
GROUP BY Status;


-- ============================================
-- 17. STATE-WISE PROFIT ANALYSIS
-- ============================================

SELECT 
    State_Code,
    COUNT(*)                                                            AS Total_Orders,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Total_Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Profit_Margin_Pct,
    ROUND(AVG(Total_Sales), 2)                                          AS Avg_Order_Value
FROM cleaned_data
GROUP BY State_Code
ORDER BY Total_Profit DESC;


-- ============================================
-- 18. CATEGORY-WISE PROFIT MARGIN
-- Full margin breakdown per category
-- ============================================

SELECT 
    Category,
    COUNT(*)                                                            AS Total_Orders,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Gross_Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Profit_Margin_Pct,
    ROUND(AVG(Total_Sales - Total_Cost), 2)                             AS Avg_Profit_Per_Order
FROM cleaned_data
GROUP BY Category
ORDER BY Profit_Margin_Pct DESC;


-- ============================================
-- 19. HIGHEST REVENUE PRODUCT
-- Single top-earning product with full detail
-- ============================================

SELECT 
    Product,
    Category,
    Brand,
    SUM(Quantity)                                                       AS Total_Units_Sold,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Total_Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Profit_Margin_Pct
FROM cleaned_data
GROUP BY Product, Category, Brand
ORDER BY Total_Revenue DESC
LIMIT 1;


-- ============================================
-- 20. SUPERVISOR-WISE PROFIT ANALYSIS
-- Extended performance metrics per supervisor
-- ============================================

SELECT 
    Assigned_Supervisor,
    COUNT(*)                                                            AS Total_Orders,
    COUNT(DISTINCT Customer_Name)                                       AS Unique_Customers,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    SUM(Total_Cost)                                                     AS Total_Cost,
    SUM(Total_Sales - Total_Cost)                                       AS Total_Profit,
    ROUND(SUM(Total_Sales - Total_Cost) / SUM(Total_Sales) * 100, 2)   AS Profit_Margin_Pct,
    ROUND(AVG(Total_Sales), 2)                                          AS Avg_Order_Value,
    SUM(Quantity)                                                       AS Total_Units_Sold
FROM cleaned_data
GROUP BY Assigned_Supervisor
ORDER BY Total_Profit DESC;


-- ============================================
-- 21. BRAND-WISE UNITS SOLD
-- Volume ranking across all brands
-- ============================================

SELECT 
    Brand,
    SUM(Quantity)                                                       AS Total_Units_Sold,
    COUNT(*)                                                            AS Total_Orders,
    SUM(Total_Sales)                                                    AS Total_Revenue,
    ROUND(AVG(Quantity), 2)                                             AS Avg_Units_Per_Order
FROM cleaned_data
GROUP BY Brand
ORDER BY Total_Units_Sold DESC;


-- ============================================
-- 22. REVENUE CONTRIBUTION PERCENTAGE BY CATEGORY
-- Shows each category's share of total revenue
-- ============================================

SELECT 
    Category,
    SUM(Total_Sales)                                                    AS Category_Revenue,
    SUM(Total_Sales - Total_Cost)                                       AS Category_Profit,
    ROUND(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER (), 2) AS Revenue_Share_Pct,
    ROUND(SUM(Total_Sales - Total_Cost) * 100.0
          / SUM(SUM(Total_Sales - Total_Cost)) OVER (), 2)              AS Profit_Share_Pct
FROM cleaned_data
GROUP BY Category
ORDER BY Revenue_Share_Pct DESC;


-- ============================================
-- 23. HIGH VALUE CUSTOMERS QUERY
-- Customers spending above the overall average
-- order value, with full behavioural profile
-- ============================================

SELECT 
    Customer_Name,
    State_Code,
    COUNT(*)                                                            AS Total_Orders,
    SUM(Total_Sales)                                                    AS Lifetime_Value,
    ROUND(AVG(Total_Sales), 2)                                          AS Avg_Order_Value,
    SUM(Quantity)                                                       AS Total_Units_Bought,
    SUM(Total_Sales - Total_Cost)                                       AS Profit_Generated,
    MIN(Order_Date)                                                     AS First_Order_Date,
    MAX(Order_Date)                                                     AS Last_Order_Date
FROM cleaned_data
GROUP BY Customer_Name, State_Code
HAVING Avg_Order_Value > (SELECT AVG(Total_Sales) FROM cleaned_data)
ORDER BY Lifetime_Value DESC;