--Code for Chapter 6
--6-1.1 Running and reverse running totals
SELECT  CustomerID ,
        FORMAT(OrderDate, 'yyyy-MM-dd') AS OrderDate ,
        SalesOrderID ,
        TotalDue ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
ROWS UNBOUNDED PRECEDING ) AS RunningTotal ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING ) AS ReverseTotal
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID;
--6.1-2 Moving sum and average
SELECT  YEAR(OrderDate) AS OrderYear ,
        MONTH(OrderDate) AS OrderMonth ,
        COUNT(*) AS OrderCount ,
        SUM(COUNT(*)) OVER ( ORDER BY YEAR(OrderDate), MONTH(OrderDate)
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS ThreeMonthCount ,
        AVG(COUNT(*)) OVER ( ORDER BY YEAR(OrderDate), MONTH(OrderDate)
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS ThreeMonthAvg
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2012-01-01'
        AND OrderDate < '2013-01-01'
GROUP BY YEAR(OrderDate) ,
        MONTH(OrderDate);

--6-2.0 Settings
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO

--6-2.1 Using the default RANGE
PRINT '6-2.1'
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS RunningTotal
FROM    Sales.SalesOrderHeader;
--6-2.2 Using ROWS
PRINT '6-2.1'
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
ROWS UNBOUNDED PRECEDING ) AS RunningTotal
FROM    Sales.SalesOrderHeader;

--6-3.0 Set up
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--6-3.1 Using the default frame
PRINT '6-3.1'
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS RunningTotal
FROM    Sales.SalesOrderHeader;

--6-3.2 Correlated subquery
PRINT '6-3.2'
SELECT  CustomerID ,
        SalesOrderID ,
        ( SELECT    SUM(TotalDue)
          FROM      Sales.SalesOrderHeader AS IQ
          WHERE     IQ.CustomerID = OQ.CustomerID
                    AND IQ.SalesOrderID >= OQ.SalesOrderID
        ) AS RunningTotal
FROM    Sales.SalesOrderHeader AS OQ;
--6-3.3 CROSS APPLY
PRINT '6-3.3'
SELECT  OQ.CustomerID ,
        OQ.SalesOrderID ,
        CA.RunningTotal
FROM    Sales.SalesOrderHeader AS OQ
        CROSS APPLY ( SELECT    SUM(TotalDue) AS RunningTotal
                      FROM      Sales.SalesOrderHeader AS IQ
                      WHERE     IQ.CustomerID = OQ.CustomerID
                                AND IQ.SalesOrderID >= OQ.SalesOrderID
                    ) AS CA;

--6-4.0 Set up
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--6-4.1
PRINT '6-4.1'
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
RANGE UNBOUNDED PRECEDING ) AS RunningSum
FROM    Sales.SalesOrderHeader;

--6-4.2 Two window functions, same OVER
PRINT '6-4.1'
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
RANGE UNBOUNDED PRECEDING ) AS RunningSum ,
        AVG(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
RANGE UNBOUNDED PRECEDING ) AS RunningAvg
FROM    Sales.SalesOrderHeader;
--6-4.3 Two window functions, different OVER
PRINT '6-4.3'
SELECT  CustomerID ,
        SalesOrderID ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
RANGE UNBOUNDED PRECEDING ) AS RunningSum ,
        AVG(TotalDue) OVER ( ORDER BY SalesOrderID
RANGE UNBOUNDED PRECEDING ) AS RunningAvg
FROM    Sales.SalesOrderHeader;

--6-5.1 Compare the logical difference between ROWS and RANGE
SELECT  CustomerID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        SalesOrderID ,
        TotalDue ,
        SUM(TotalDue) OVER ( ORDER BY OrderDate
ROWS UNBOUNDED PRECEDING ) AS RunningTotalRows ,
        SUM(TotalDue) OVER ( ORDER BY OrderDate
RANGE UNBOUNDED PRECEDING ) AS RunningTotalRange
FROM    Sales.SalesOrderHeader
WHERE   CustomerID = 11300
ORDER BY SalesOrderID;

--6-6.1 Look at the older technique
SELECT  CustomerID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        SalesOrderID ,
        TotalDue ,
        ( SELECT    SUM(TotalDue)
          FROM      Sales.SalesOrderHeader AS IQ
          WHERE     IQ.CustomerID = OQ.CustomerID
                    AND IQ.OrderDate <= OQ.OrderDate
        ) AS RunningTotal
FROM    Sales.SalesOrderHeader AS OQ
WHERE   CustomerID = 11300
ORDER BY SalesOrderID;




