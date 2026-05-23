USE Techno_Sales_DB1;
CREATE TABLE sales_data3 (
    Order_Number    INT,
    State_Code      VARCHAR(5),
    Customer_Name   VARCHAR(100),
    Order_Date      DATE,
    "Status"         VARCHAR(20),
    Products         VARCHAR(100),
    Category        VARCHAR(50),
    Brand           VARCHAR(50),
    Cost            DECIMAL(10,2),
    Sales           DECIMAL(10,2),
    Quantity        INT,
    Total_Cost      DECIMAL(10,2),
    Total_Sales     DECIMAL(10,2),
    Supervisor      VARCHAR(100)
);
use Techno_Sales_DB1;
select * from [dbo].[Sales_Data$];
select * from [dbo].[State_list$];
use Techno_Sales_DB1;
DROP TABLE dbo.sales_data3;
use Techno_Sales_DB1;
select * from [dbo].[Supervisor$];
USE Techno_Sales_DB1;
DROP  table dbo.sales_data1;
use Techno_Sales_DB1;
drop table dbo.sales_data2;

-- extract Total Revenue
use Techno_Sales_DB1;
SELECT 
    SUM(Total_Sales) AS Total_Revenue,
    AVG(Total_Sales) AS Average_Revenue_Per_Order,
    SUM(Quantity) AS Total_Items_Sold
FROM [dbo].[Sales_Data$];

----Extract Best-Selling Products by Volume (Quantity)

USE Techno_Sales_DB1;

SELECT 
    Product,
    SUM(Quantity) AS Total_Volume_Sold
FROM [dbo].[Sales_Data$]
GROUP BY 
    Product
ORDER BY 
    Total_Volume_Sold DESC;
USE Techno_Sales_DB1;

SELECT 
    State_Code,
    COUNT(Order_Number) AS Total_Orders,
    SUM(Quantity) AS Total_Units_Sold,
    SUM(Total_Sales) AS Total_Geographic_Revenue,
    AVG(Total_Sales) AS Avg_Sale_Per_Order
FROM [dbo].[Sales_Data$]
GROUP BY 
    State_Code
ORDER BY 
    Total_Geographic_Revenue DESC;
