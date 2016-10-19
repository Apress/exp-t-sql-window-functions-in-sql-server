--Code for Chapter 8
--8-1.1 Using PERCENT_RANK and CUME_DIST
SELECT  COUNT(*) NumberOfOrders ,
        MONTH(OrderDate) AS OrderMonth ,
        RANK() OVER ( ORDER BY COUNT(*) ) AS Ranking ,
        PERCENT_RANK() OVER ( ORDER BY COUNT(*) ) AS PercentRank ,
        CUME_DIST() OVER ( ORDER BY COUNT(*) ) AS CumeDist
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-2.1 Find median for the set
SELECT  COUNT(*) NumberOfOrders ,
        MONTH(OrderDate) AS orderMonth ,
        PERCENTILE_CONT(.5) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileCont ,
        PERCENTILE_DISC(.5) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileDisc
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-2.2 Return just the answer
SELECT DISTINCT
        PERCENTILE_CONT(.5) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileCont ,
        PERCENTILE_DISC(.5) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileDisc
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-3.1 Filter out January
SELECT DISTINCT
        PERCENTILE_CONT(.5) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileCont ,
        PERCENTILE_DISC(.5) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileDisc
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-02-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-4.1 Set up variables and table
DECLARE @score DECIMAL(5, 2)
DECLARE @count INT = 1;
CREATE TABLE #scores
    (
      StudentID INT IDENTITY ,
      Score DECIMAL(5, 2)
    );
--8-4.2 Loop to generate 1000 scores
WHILE @count <= 1000
    BEGIN
        SET @score = CAST(RAND() * 100 AS DECIMAL(5, 2));
        INSERT  INTO #scores
                ( Score )
        VALUES  ( @score );
        SET @count += 1;
    END;

--8-4.3 Return the score at the top 25%
SELECT DISTINCT
        PERCENTILE_DISC(.25) WITHIN GROUP ( ORDER BY Score DESC ) OVER ( ) AS Top25
FROM    #scores;

--8-5.1 Using 2005 functionality
SELECT  COUNT(*) NumberOfOrders ,
        MONTH(OrderDate) AS OrderMonth ,
        ( ( RANK() OVER ( ORDER BY COUNT(*) ) - 1 ) * 1.0 )
        / ( COUNT(*) OVER ( ) - 1 ) AS PercentRank ,
        ( RANK() OVER ( ORDER BY COUNT(*) ) * 1.0 ) / COUNT(*) OVER ( ) AS CumeDist
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-6.1 PERCENTILE_DISC
SELECT DISTINCT
        PERCENTILE_DISC(0.75) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentileDisc
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-6.2 Old method
WITH    Level1
          AS ( SELECT   COUNT(*) NumberOfOrders ,
                        ( ( RANK() OVER ( ORDER BY COUNT(*) ) - 1 ) * 1.0 )
                        / ( COUNT(*) OVER ( ) - 1 ) AS PercentRank
               FROM     Sales.SalesOrderHeader
               WHERE    OrderDate >= '2013-01-01'
                        AND OrderDate < '2014-01-01'
               GROUP BY MONTH(OrderDate)
             )
    SELECT TOP ( 1 )
            NumberOfOrders AS PercentileDisc
    FROM    Level1
    WHERE   Level1.PercentRank <= 0.75
    ORDER BY Level1.PercentRank DESC;

--8-7.1 PERCENTILE_CONT
SELECT DISTINCT
        PERCENTILE_CONT(0.75) WITHIN GROUP ( ORDER BY COUNT(*) )
OVER ( ) AS PercentCont
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
        AND OrderDate < '2014-01-01'
GROUP BY MONTH(OrderDate);

--8-7.2 Using 2005 functionality
WITH    Level1
          AS ( SELECT   COUNT(*) NumberOfOrders ,
                        CAST(( RANK() OVER ( ORDER BY COUNT(*) ) - 1 ) AS FLOAT)
                        / ( COUNT(*) OVER ( ) - 1 ) AS PercentRank
               FROM     Sales.SalesOrderHeader
               WHERE    OrderDate >= '2013-01-01'
                        AND OrderDate < '2014-01-01'
               GROUP BY MONTH(OrderDate)
             ),
        Level2
          AS ( SELECT   NumberOfOrders ,
                        SIGN(PercentRank - 0.75) AS SGN ,
                        ROW_NUMBER() OVER ( PARTITION BY SIGN(PercentRank
                                                              - 0.75) ORDER BY ABS(PercentRank
                                                              - 0.75) ) AS rownumber
               FROM     Level1
             ),
        Level3
          AS ( SELECT   SUM(CASE WHEN SGN = 0 THEN NumberOfOrders
                            END) AS ExactRow ,
                        SUM(CASE WHEN SGN = -1 THEN NumberOfOrders
                            END) AS LowerRow ,
                        SUM(CASE WHEN SGN = 1 THEN NumberOfOrders
                            END) AS UpperRow
               FROM     Level2
               WHERE    rownumber = 1
             )
    SELECT  CASE WHEN ExactRow IS NOT NULL THEN ExactRow
                 ELSE UpperRow - ( UpperRow - LowerRow ) * 0.75
            END AS PercentCont
    FROM    Level3;



