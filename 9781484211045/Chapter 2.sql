--Code for Chapter 2
USE AdventureWorks;    
GO    
--2-1.1 Using ROW_NUMBER with and without a PARTITION BY    
SELECT  CustomerID ,
        FORMAT(OrderDate, 'yyyy-MM-dd') AS OrderDate ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY SalesOrderID ) AS WithPart ,
        ROW_NUMBER() OVER ( ORDER BY CustomerID ) AS WithoutPart
FROM    Sales.SalesOrderHeader;  

--2-2.1 Query ORDER BY ascending    
SELECT  CustomerID ,
        OrderDate ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( ORDER BY CustomerID ) AS RowNumber
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID;   
--2-2.2 Query ORDER BY descending    
SELECT  CustomerID ,
        OrderDate ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( ORDER BY CustomerID ) AS RowNumber
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID DESC;   

--2-3.1 Using ROW_NUMBER a unique ORDER BY   
SELECT  CustomerID ,
        OrderDate ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( ORDER BY CustomerID, SalesOrderID ) AS RowNum
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID; 
		
  
--2-3.2 Change to descending    
SELECT  CustomerID ,
        OrderDate ,
        SalesOrderID ,
        ROW_NUMBER() OVER ( ORDER BY CustomerID, SalesOrderID ) AS RowNum
FROM    Sales.SalesOrderHeader
ORDER BY CustomerID ,
        SalesOrderID DESC;   

--2-4.1 Using RANK and DENSE_RANK    
SELECT  CustomerID ,
        OrderDate ,
        ROW_NUMBER() OVER ( ORDER BY OrderDate ) AS RowNumber ,
        RANK() OVER ( ORDER BY OrderDate ) AS [Rank] ,
        DENSE_RANK() OVER ( ORDER BY OrderDate ) AS DenseRank
FROM    Sales.SalesOrderHeader
WHERE   CustomerID IN ( 11330, 29676 );   

--2.5.1 Using NTILE    
WITH    Orders
          AS ( SELECT   MONTH(OrderDate) AS OrderMonth ,
                        FORMAT(SUM(TotalDue), 'C') AS Sales
               FROM     Sales.SalesOrderHeader
               WHERE    OrderDate >= '2013/01/01'
                        AND OrderDate < '2014/01/01'
               GROUP BY MONTH(OrderDate)
             )
    SELECT  OrderMonth ,
            Sales ,
            NTILE(4) OVER ( ORDER BY Sales ) AS Bucket
    FROM    Orders;   


--2.6.1 Using NTILE with uneven buckets    
WITH    Orders
          AS ( SELECT   MONTH(OrderDate) AS OrderMonth ,
                        FORMAT(SUM(TotalDue), 'C') AS Sales
               FROM     Sales.SalesOrderHeader
               WHERE    OrderDate >= '2013/01/01'
                        AND OrderDate < '2014/01/01'
               GROUP BY MONTH(OrderDate)
             )
    SELECT  OrderMonth ,
            Sales ,
            NTILE(5) OVER ( ORDER BY Sales ) AS Bucket
    FROM    Orders;   

--2-7.1 Create a table that will hold duplicate rows    
CREATE TABLE #dupes ( Col1 INT, Col2 CHAR(1) );       
--2-7.2 Insert some rows    
INSERT  INTO #dupes
        ( Col1, Col2 )
VALUES  ( 1, 'a' ),
        ( 1, 'a' ),
        ( 2, 'b' ),
        ( 3, 'c' ),
        ( 4, 'd' ),
        ( 4, 'd' ),
        ( 5, 'e' );       
--2-7.3    
SELECT Col1, Col2    
FROM #dupes;   

--2-8.1 Add ROW_NUMBER and Partition by all of the columns    
SELECT  Col1 ,
        Col2 ,
        ROW_NUMBER() OVER ( PARTITION BY Col1, Col2 ORDER BY Col1 ) AS RowNumber
FROM    #dupes;       
--2-8.2 Delete the rows with RowNumber > 1    
WITH    Dupes
          AS ( SELECT   Col1 ,
                        Col2 ,
                        ROW_NUMBER() OVER ( PARTITION BY Col1, Col2 ORDER BY Col1 ) AS RowNumber
               FROM     #dupes
             )
    DELETE  Dupes
    WHERE   RowNumber > 1;       
--2-8.3 The results    
SELECT Col1, Col2    
FROM #dupes;   


--2-9.1 Using CROSS APPLY to find the first four orders    
WITH    Months
          AS ( SELECT   MONTH(OrderDate) AS OrderMonth
               FROM     Sales.SalesOrderHeader
               WHERE    OrderDate >= '2013-01-01'
                        AND OrderDate < '2014-01-01'
               GROUP BY MONTH(OrderDate)
             )
    SELECT  OrderMonth ,
            CA.OrderDate ,
            CA.SalesOrderID ,
            CA.TotalDue
    FROM    Months
            CROSS APPLY ( SELECT TOP ( 4 )
                                    SalesOrderID ,
                                    OrderDate ,
                                    TotalDue
                          FROM      Sales.SalesOrderHeader AS IQ
                          WHERE     OrderDate >= '2013-01-01'
                                    AND OrderDate < '2014-01-01'
                                    AND MONTH(IQ.OrderDate) = Months.OrderMonth
                          ORDER BY  SalesOrderID
                        ) AS CA
    ORDER BY OrderMonth ,
            SalesOrderID;       
--2-9.2 Use ROW_NUMBER to find the first four orders    
WITH    Orders
          AS ( SELECT   MONTH(OrderDate) AS OrderMonth ,
                        OrderDate ,
                        SalesOrderID ,
                        TotalDue ,
                        ROW_NUMBER() OVER ( PARTITION BY MONTH(OrderDate) ORDER BY SalesOrderID ) AS RowNumber
               FROM     Sales.SalesOrderHeader
               WHERE    OrderDate >= '2013-01-01'
                        AND OrderDate < '2014-01-01'
             )
    SELECT  OrderMonth ,
            OrderDate ,
            SalesOrderID ,
            TotalDue
    FROM    Orders
    WHERE   RowNumber <= 4
    ORDER BY OrderMonth ,
            SalesOrderID;  
			
 --2-10.1 Create the #Islands table    
 CREATE TABLE #Islands ( ID INT NOT NULL );       
 --2-10.2 Populate the #Islands table    
 INSERT INTO #Islands
        ( ID )
 VALUES ( 101 ),
        ( 102 ),
        ( 103 ),
        ( 106 ),
        ( 108 ),
        ( 108 ),
        ( 109 ),
        ( 110 ),
        ( 111 ),
        ( 112 ),
        ( 112 ),
        ( 114 ),
        ( 115 ),
        ( 118 ),
        ( 119 );       
--2-10.3 View the data    
SELECT ID    
FROM #Islands;      

--2-11.1 Add ROW_NUMBER to the data    
SELECT  ID ,
        ROW_NUMBER() OVER ( ORDER BY ID ) AS RowNum
FROM    #Islands;       
--2-11.2 Subtract the RowNum from the ID    
SELECT  ID ,
        ROW_NUMBER() OVER ( ORDER BY ID ) AS RowNum ,
        ID - ROW_NUMBER() OVER ( ORDER BY ID ) AS Diff
FROM    #Islands;       
--2-11.3 Change to DENSE_RANK since there are duplicates    
SELECT  ID ,
        DENSE_RANK() OVER ( ORDER BY ID ) AS DenseRank ,
        ID - DENSE_RANK() OVER ( ORDER BY ID ) AS Diff
FROM    #Islands;       
--2-11.4 The complete Islands solution    
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

--2-12.1 Using NTILE to assign bonuses    
WITH    Sales
          AS ( SELECT   SP.FirstName ,
                        SP.LastName ,
                        SUM(SOH.TotalDue) AS TotalSales
               FROM     [Sales].[vSalesPerson] SP
                        JOIN Sales.SalesOrderHeader SOH ON SP.BusinessEntityID = SOH.SalesPersonID
               WHERE    SOH.OrderDate >= '2011-01-01'
                        AND SOH.OrderDate < '2012-01-01'
               GROUP BY FirstName ,
                        LastName
             )
    SELECT  FirstName ,
            LastName ,
            TotalSales ,
            NTILE(4) OVER ( ORDER BY TotalSales ) * 1000 AS Bonus
    FROM    Sales;   

