--Code for Chapter 5

--5-1.1 A running total
SELECT  CustomerID ,
        SalesOrderID ,
        CAST(OrderDate AS DATE) AS OrderDate ,
        TotalDue ,
        SUM(TotalDue) OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS RunningTotal
FROM    Sales.SalesOrderHeader;

--5-2.1 Three month sum and average for products qty sold
SELECT  MONTH(SOH.OrderDate) AS OrderMonth ,
        SOD.ProductID ,
        SUM(SOD.OrderQty) AS QtySold ,
        SUM(SUM(SOD.OrderQty)) OVER ( PARTITION BY SOD.ProductID ORDER BY MONTH(SOH.OrderDate)
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS ThreeMonthSum ,
        AVG(SUM(SOD.OrderQty)) OVER ( PARTITION BY SOD.ProductID ORDER BY MONTH(SOH.OrderDate)
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS ThreeMonthAvg
FROM    Sales.SalesOrderHeader AS SOH
        JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
        JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(SOH.OrderDate) ,
        SOD.ProductID;

--5-3.1 Create the table
CREATE TABLE #TheTable ( ID INT, Data INT );
--5-3.2 Populate the table
INSERT  INTO #TheTable
        ( ID, Data )
VALUES  ( 1, 1 ),
        ( 2, 1 ),
        ( 3, NULL ),
        ( 4, NULL ),
        ( 5, 6 ),
        ( 6, NULL ),
        ( 7, 5 ),
        ( 8, 10 ),
        ( 9, 11 );
--5-3.3 Display the results
SELECT  *
FROM    #TheTable;

--5-4.1 Find the max non-null row
SELECT  ID ,
        Data ,
        MAX(CASE WHEN Data IS NOT NULL THEN ID
            END) OVER ( ORDER BY ID ) AS MaxRow
FROM    #TheTable;

--5-5.1 The solution
WITH    MaxData
          AS ( SELECT   ID ,
                        Data ,
                        MAX(CASE WHEN Data IS NOT NULL THEN ID
                            END) OVER ( ORDER BY ID ) AS MaxRow
               FROM     #TheTable
             )
    SELECT  ID ,
            Data ,
            MAX(Data) OVER ( PARTITION BY MaxRow ) AS NewData
    FROM    MaxData;

/*
Download the data from 
www.simple-talk.com/sql/performance/writing-efficient-sql-set-based-speed-phreakery/ 
*/
--5-6.1 The subscription data
SELECT  *
FROM    Registrations;

--5-7.1 Solve the subscription problem
WITH    NewSubs
          AS ( SELECT   EOMONTH(DateJoined) AS TheMonth ,
                        COUNT(DateJoined) AS PeopleJoined
               FROM     Registrations
               GROUP BY EOMONTH(DateJoined)
             ),
        Cancelled
          AS ( SELECT   EOMONTH(DateLeft) AS TheMonth ,
                        COUNT(DateLeft) AS PeopleLeft
               FROM     Registrations
               GROUP BY EOMONTH(DateLeft)
             )
    SELECT  NewSubs.TheMonth AS TheMonth ,
            NewSubs.PeopleJoined ,
            Cancelled.PeopleLeft ,
            SUM(NewSubs.PeopleJoined - ISNULL(Cancelled.PeopleLeft, 0)) OVER ( ORDER BY NewSubs.TheMonth ) AS Subscriptions
    FROM    NewSubs
            LEFT JOIN Cancelled ON NewSubs.TheMonth = Cancelled.TheMonth;




