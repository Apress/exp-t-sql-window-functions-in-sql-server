--Code for Chapter 4
--4-1.1 Query to produce Sequence Project
SELECT  CustomerID ,
        ROW_NUMBER() OVER ( ORDER BY SalesOrderID ) AS RowNumber
FROM    Sales.SalesOrderHeader;

--4-2.1 A query to show the Sort operator
SELECT  CustomerID ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY OrderDate ) AS RowNumber
FROM    Sales.SalesOrderHeader;

--4-3.1 A query with a Table Spool operator
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ) AS SubTotal
FROM    Sales.SalesOrderHeader;

--4.4.0 Settings
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--4-4.1 Query to produce Sequence Project
PRINT '4-4.1';
SELECT  CustomerID ,
        ROW_NUMBER() OVER ( ORDER BY SalesOrderID ) AS RowNumber
FROM    Sales.SalesOrderHeader;

--4-4.2 A query to show the Sort operator
PRINT '4-4.2';
SELECT  CustomerID ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY OrderDate ) AS RowNumber
FROM    Sales.SalesOrderHeader;

--4-4.3 A query with a Table Spool operator
PRINT '4-4.3';
SELECT CustomerID, SalesOrderID, SUM(TotalDue) OVER(PARTITION BY CustomerID)
AS SubTotal
FROM Sales.SalesOrderHeader;

--4-5.0 Settings
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--4-5.1 CTE
PRINT '4-5.1 CTE';
WITH    Totals
          AS ( SELECT   CustomerID ,
                        SUM(TotalDue) AS CustomerTotal
               FROM     Sales.SalesOrderHeader
               GROUP BY CustomerID
             )
    SELECT  SOH.CustomerID ,
            SalesOrderID ,
            OrderDate ,
            TotalDue ,
            CustomerTotal
    FROM    Sales.SalesOrderHeader AS SOH
            JOIN Totals ON SOH.CustomerID = Totals.CustomerID;

--4-5.1 The same results using a window aggregate
PRINT '4-5.2 The window aggregate';
SELECT  CustomerID ,
        SalesOrderID ,
        OrderDate ,
        TotalDue ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ) AS CustomerTotal
FROM    Sales.SalesOrderHeader;

--4-6.1 Drop the existing index
DROP INDEX [IX_SalesOrderHeader_CustomerID] ON [Sales].[SalesOrderHeader];
GO
--4-6.2 Create a new index for the query
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID_OrderDate]
ON [Sales].[SalesOrderHeader] ([CustomerID], [OrderDate]);

--4-7.1 query with a join
SELECT  SOH.CustomerID ,
        SOH.SalesOrderID ,
        SOH.OrderDate ,
        C.TerritoryID ,
        ROW_NUMBER() OVER ( PARTITION BY SOH.CustomerID ORDER BY SOH.OrderDate ) AS RowNumber
FROM    Sales.SalesOrderHeader AS SOH
        JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID;

--4-7.2 Rearrange the query
WITH    Sales
          AS ( SELECT   CustomerID ,
                        OrderDate ,
                        SalesOrderID ,
                        ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY OrderDate ) AS RowNumber
               FROM     Sales.SalesOrderHeader
             )
    SELECT  Sales.CustomerID ,
            Sales.SalesOrderID ,
            Sales.OrderDate ,
            C.TerritoryID ,
            Sales.RowNumber
    FROM    Sales
            JOIN Sales.Customer AS C ON C.CustomerID = Sales.CustomerID;

--4-8.0 Settings
SET STATISTICS IO OFF;
SET STATISTICS TIME ON;
SET NOCOUNT ON;
GO
--4-8.1 The join query
PRINT '4-8.1';
SELECT  SOH.CustomerID ,
        SOH.SalesOrderID ,
        SOH.OrderDate ,
        C.TerritoryID ,
        ROW_NUMBER() OVER ( PARTITION BY SOH.CustomerID ORDER BY SOH.OrderDate ) AS RowNumber
FROM    Sales.SalesOrderHeader AS SOH
        JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID;

--4-8.2 The CTE
PRINT '4-8.2';
WITH    Sales
          AS ( SELECT   CustomerID ,
                        OrderDate ,
                        SalesOrderID ,
                        ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY OrderDate ) AS RowNumber
               FROM     Sales.SalesOrderHeader
             )
    SELECT  Sales.CustomerID ,
            Sales.SalesOrderID ,
            Sales.OrderDate ,
            C.TerritoryID ,
            Sales.RowNumber
    FROM    Sales
            JOIN Sales.Customer AS C ON C.CustomerID = Sales.CustomerID;

--4-9.0 Set up a loop
DECLARE @count INT = 0;
WHILE @count < 1000
    BEGIN
--4-9.1 The query
        SELECT  SOH.CustomerID ,
                SalesOrderID ,
                OrderDate ,
                C.TerritoryID ,
                ROW_NUMBER() OVER ( PARTITION BY SOH.CustomerID ORDER BY OrderDate ) AS RowNumber
        FROM    Sales.SalesOrderHeader AS SOH
                JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID;
        SET @count += 1;
    END;

GO
--4-10.0 Set up a loop
DECLARE @count INT = 0;
WHILE @count < 1000 BEGIN
	--4-10.1 The query
	WITH Sales AS (
	SELECT CustomerID, OrderDate, SalesOrderID,
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate)
	AS RowNumber
	FROM Sales.SalesOrderHeader)
	SELECT Sales.CustomerID, SALES.SalesOrderID, Sales.OrderDate, C.TerritoryID,
	Sales.RowNumber
	FROM Sales
	JOIN Sales.Customer AS C ON C.CustomerID = Sales.CustomerID;
	SET @count += 1;
END;

--4-11.1 Drop index
DROP INDEX [IX_SalesOrderHeader_CustomerID_OrderDate] ON Sales.
SalesOrderHeader;
GO
--4-11-2 Recreate original index
CREATE INDEX [IX_SalesOrderHeader_CustomerID] ON Sales.SalesOrderHeader
(CustomerID);





