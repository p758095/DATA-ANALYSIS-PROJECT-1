# STEP 1: CREATE A DATABAE:
CREATE DATABASE SalesAnalysis;
USE SalesAnalysis;

#CREATE TABLES AS REQUIRED:
CREATE TABLE Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName VARCHAR(100),
    Segment VARCHAR(50),
    Age INT,
    Country VARCHAR(50),
    Region VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode INT
);

CREATE TABLE Products (
    ProductID VARCHAR(20) PRIMARY KEY,
    Category VARCHAR(100),
    SubCategory VARCHAR(100),
    ProductName VARCHAR(255),
    Segment VARCHAR(50),
    Price DECIMAL(10,2)
);

CREATE TABLE Sales (
    SaleID VARCHAR(20) PRIMARY KEY,
    CustomerID VARCHAR(20),
    ProductID VARCHAR(20),
    SaleDate DATE,
    Quantity INT CHECK (Quantity > 0),  -- Ensure positive values
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
# here we have imported all dataset set in tables;

# STEP 2: VERIFY THE DATA INTEGRITY FIRST:

#Check total number of records in each table
SELECT COUNT(*) AS TotalCustomers FROM Customers; 
SELECT COUNT(*) AS TotalProducts FROM Products; 
SELECT COUNT(*) AS TotalSales FROM Sales;

# check the missing references in sales table to insure relational integrity:
SELECT DISTINCT CustomerID FROM Sales WHERE CustomerID NOT IN (SELECT CustomerID FROM Customers);
SELECT DISTINCT ProductID FROM Sales WHERE ProductID NOT IN (SELECT ProductID FROM Products);

# check duplicate records in sales table to mantain data consistency;
SELECT CustomerID, ProductID, SaleDate, COUNT(*) 
FROM Sales 
GROUP BY  CustomerID, ProductID, SaleDate
HAVING COUNT(*) > 1;

# removing the duplicate records from sales table to determine accuracy of entries :
DELETE FROM Sales 
WHERE CustomerID = 'B-00049';

# STEP 3: PERFORM FINALNCIAL ANALYSTIS;

# total revenue generated on overall sales;
SELECT SUM(TotalAmount) AS TotalRevenue FROM Sales;

# average order value:
SELECT AVG(TotalAmount) AS AvgOrderValue FROM Sales;

# monthly sales revenue;
SELECT YEAR(SaleDate) AS Year, MONTH(SaleDate) AS Month, SUM(TotalAmount) AS MonthlyRevenue 
FROM Sales 
GROUP BY Year, Month 
ORDER BY Year DESC, Month DESC;


# STEP 4: PERFORM CUSTOMER SEGMENT ANALYSIS;

# top 5 customers, based on purchase 
SELECT CustomerID, COUNT(SaleID) AS TotalOrders, SUM(TotalAmount) AS TotalSpent 
FROM Sales 
GROUP BY CustomerID 
ORDER BY TotalSpent DESC 
LIMIT 5;

# segment wise sales contribution;
SELECT Customers.Segment, SUM(Sales.TotalAmount) AS SegmentRevenue 
FROM Sales
JOIN Customers ON Sales.CustomerID = Customers.CustomerID 
GROUP BY Customers.Segment 
ORDER BY SegmentRevenue DESC;

# finding customer retention;
SELECT CustomerID, COUNT(SaleID) AS PurchaseCount 
FROM Sales 
GROUP BY CustomerID 
HAVING PurchaseCount > 1 
ORDER BY PurchaseCount DESC 
LIMIT 10;

# STEP 5: PRODUCT PERFORMANCE ANALYSIS;

# top 5 selling products;
SELECT Products.ProductID, ProductName, COUNT(SaleID) AS SalesCount, SUM(TotalAmount) AS RevenueGenerated 
FROM Sales 
JOIN Products ON Sales.ProductID = Products.ProductID 
GROUP BY Products.ProductID, ProductName 
ORDER BY SalesCount DESC 
LIMIT 5;

# top 5 least performing products;
SELECT Products.ProductID, ProductName, COUNT(SaleID) AS SalesCount 
FROM Sales 
JOIN Products ON Sales.ProductID = Products.ProductID 
GROUP BY Products.ProductID, ProductName 
ORDER BY SalesCount ASC 
LIMIT 5;

# category wise sales distribution;
SELECT Products.Category, SUM(Sales.TotalAmount) AS RevenueByCategory 
FROM Sales
JOIN Products ON Sales.ProductID = Products.ProductID 
GROUP BY Products.Category 
ORDER BY RevenueByCategory DESC;

# STEP 6: ADVANCE BUSINESS INSIGHTS
# average sales segment-wise per customer;
SELECT Customers.Segment, AVG(Sales.TotalAmount) AS AvgSegmentSpend 
FROM Sales 
JOIN Customers ON Sales.CustomerID = Customers.CustomerID 
GROUP BY Customers.Segment;

# identify seasonal demands;
SELECT MONTH(SaleDate) AS SaleMonth, SUM(TotalAmount) AS MonthlyRevenue 
FROM Sales 
GROUP BY SaleMonth 
ORDER BY MonthlyRevenue DESC;


