--Code for Chapter 7

--7-1.1 Use LAG and LEAD
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        LAG(CAST(OrderDate AS DATE)) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS PrevOrderDate ,
        LEAD(CAST(OrderDate AS DATE)) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS NextOrderDate
FROM    Sales.SalesOrderHeader;

--7-1.2 Use LAG and LEAD as an argument
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        DATEDIFF(DAY,
                 LAG(OrderDate) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ),
                 OrderDate) AS DaysSincePrevOrder ,
        DATEDIFF(DAY, OrderDate,
                 LEAD(OrderDate) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID )) AS DaysUntilNextOrder
FROM    Sales.SalesOrderHeader;

--7-2.1 Using Offset with LAG
WITH    Totals
          AS ( SELECT   YEAR(OrderDate) AS OrderYear ,
                        MONTH(OrderDate) / 4 + 1 AS OrderQtr ,
                        SUM(TotalDue) AS TotalSales
               FROM     Sales.SalesOrderHeader
               GROUP BY YEAR(OrderDate) ,
                        MONTH(OrderDate) / 4 + 1
             )
    SELECT  OrderYear ,
            Totals.OrderQtr ,
            TotalSales ,
            LAG(TotalSales, 4) OVER ( ORDER BY OrderYear, OrderQtr ) AS PreviousYearsSales
    FROM    Totals
    ORDER BY OrderYear ,
            OrderQtr;

--7-3.1 Using Offset with LAG
WITH    Totals
          AS ( SELECT   YEAR(OrderDate) AS OrderYear ,
                        MONTH(OrderDate) / 4 + 1 AS OrderQtr ,
                        SUM(TotalDue) AS TotalSales
               FROM     Sales.SalesOrderHeader
               GROUP BY YEAR(OrderDate) ,
                        MONTH(OrderDate) / 4 + 1
             )
    SELECT  OrderYear ,
            Totals.OrderQtr ,
            TotalSales ,
            LAG(TotalSales, 4, 0) OVER ( ORDER BY OrderYear, OrderQtr ) AS PreviousYearsSales
    FROM    Totals
    ORDER BY OrderYear ,
            OrderQtr;

--7-4.1 Using FIRST_VALUE and LAST_VALUE
SELECT  CustomerID ,
        SalesOrderID ,
        TotalDue ,
        FIRST_VALUE(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS FirstOrderAmt ,
        LAST_VALUE(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS LastOrderAmt_WRONG ,
        LAST_VALUE(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING ) AS LastOrderAmt
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID;

--7-5.1 Calculate Year-Over-Year Growth
WITH    Level1
          AS ( SELECT   YEAR(OrderDate) AS SalesYear ,
                        MONTH(OrderDate) AS SalesMonth ,
                        SUM(TotalDue) AS TotalSales
               FROM     Sales.SalesOrderHeader
               GROUP BY YEAR(OrderDate) ,
                        MONTH(OrderDate)
             ),
        Level2
          AS ( SELECT   SalesYear ,
                        SalesMonth ,
                        TotalSales ,
                        LAG(TotalSales, 12) OVER ( ORDER BY SalesYear ) AS PrevYearSales
               FROM     Level1
             )
    SELECT  SalesYear ,
            SalesMonth ,
            FORMAT(TotalSales, 'C') AS TotalSales ,
            FORMAT(PrevYearSales, 'C') AS PrevYearSales ,
            FORMAT(( TotalSales - PrevYearSales ) / PrevYearSales, 'P') AS YOY_Growth
    FROM    Level2
    WHERE   PrevYearSales IS NOT NULL;

--7-6.1 Create the #Islands table
CREATE TABLE #Islands ( ID INT NOT NULL );
--7-6.2 Populate the #Islands table
INSERT  INTO #Islands
        ( ID )
VALUES  ( 1 ),
        ( 2 ),
        ( 3 ),
        ( 6 ),
        ( 8 ),
        ( 8 ),
        ( 9 ),
        ( 10 ),
        ( 11 ),
        ( 12 ),
        ( 12 ),
        ( 14 ),
        ( 15 ),
        ( 18 ),
        ( 19 );
--7-6.3 The Islands
WITH    Islands
          AS ( SELECT   ID ,
                        DENSE_RANK() OVER ( ORDER BY ID ) AS DenseRank ,
                        ID - DENSE_RANK() OVER ( ORDER BY ID ) AS Diff
               FROM     #Islands
             )
    SELECT  MIN(ID) AS IslandStart ,
            MAX(ID) AS IslandEnd
    FROM    Islands
    GROUP BY Diff;
--7-7.1 Find the Gaps
WITH    Level1
          AS ( SELECT   ID ,
                        DENSE_RANK() OVER ( ORDER BY ID ) AS DenseRank ,
                        ID - DENSE_RANK() OVER ( ORDER BY ID ) AS Diff
               FROM     #Islands
             ),
        Level2
          AS ( SELECT   MIN(ID) AS IslandStart ,
                        MAX(ID) AS IslandEnd
               FROM     Level1
               GROUP BY Diff
             ),
        Level3
          AS ( SELECT   IslandEnd + 1 AS GapStart ,
                        LEAD(IslandStart) OVER ( ORDER BY IslandStart ) - 1 AS GapEnd
               FROM     Level2
             )
    SELECT  GapStart ,
            GapEnd
    FROM    Level3
    WHERE   GapEnd IS NOT NULL;

--7-8.0 Set up
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--7-8.1 Use LAG and LEAD
PRINT '7-8.1'
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        LAG(CAST(OrderDate AS DATE)) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS PrevOrderDate
FROM    Sales.SalesOrderHeader;
--7-8.2 Use Correlated Subquery
PRINT '7-8.2'
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        ( SELECT TOP ( 1 )
                    CAST(OrderDate AS DATE)
          FROM      Sales.SalesOrderHeader AS IQ
          WHERE     IQ.CustomerID = OQ.CustomerID
                    AND IQ.SalesOrderID < OQ.SalesOrderID
          ORDER BY  SalesOrderID
        ) AS PrevOrderDate
FROM    Sales.SalesOrderHeader AS OQ;
--7-8.3 Use OUTER APPLY
PRINT '7-8.3'
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        OA.PrevOrderDate
FROM    Sales.SalesOrderHeader AS OQ
        OUTER APPLY ( SELECT TOP ( 1 )
                                CAST(OrderDate AS DATE) AS PrevOrderDate
                      FROM      Sales.SalesOrderHeader AS IQ
                      WHERE     IQ.CustomerID = OQ.CustomerID
                                AND IQ.SalesOrderID < OQ.SalesOrderID
                      ORDER BY  SalesOrderID
                    ) AS OA;

--7-9.0 Set up
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--7-9.1 A dynamic offset
DECLARE @Offset INT = 1;
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        LAG(CAST(OrderDate AS DATE), @Offset) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS PrevOrderDate
FROM    Sales.SalesOrderHeader;

--7-10.0 Set up
SET STATISTICS IO ON;
SET NOCOUNT ON;
GO
--7-10.1 Default frame
PRINT '7-10.1'
SELECT  CustomerID ,
        SalesOrderID ,
        TotalDue ,
        FIRST_VALUE(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS FirstOrderAmt
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID;
--7-10.2 ROWS
PRINT '7-10.2'
SELECT  CustomerID ,
        SalesOrderID ,
        TotalDue ,
        FIRST_VALUE(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ROWS UNBOUNDED PRECEDING ) AS FirstOrderAmt
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID;




