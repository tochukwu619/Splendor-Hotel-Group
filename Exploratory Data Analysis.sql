-- SPLENDOR HOTEL GROUPS

-- EXPLORATORY DATA ANALYSIS


-- FIRST WE VIEW THE TOP 1000 ROWS OF DATA


SELECT TOP (1000) [Booking ID]
      ,[Hotel]
      ,[Booking Date]
      ,[Arrival Date]
      ,[Lead Time]
      ,[Nights]
      ,[Guests]
      ,[Distribution Channel]
      ,[Customer Type]
      ,[Country]
      ,[Deposit Type]
      ,[Avg Daily Rate]
      ,[Status]
      ,[Status Update]
      ,[Cancelled (0/1)]
      ,[Revenue]
      ,[Revenue Loss]
      ,[F18]
  FROM [Splendor_Hotel_Groups].[dbo].[SHG]


  -- REMOVE THE LAST COLUMN

ALTER TABLE SHG
DROP COLUMN F18;


SELECT TOP (1000) *
FROM SHG;



-- RENAMING SOME COLUMNS


USE Splendor_Hotel_Groups;
GO

EXEC sp_rename 'SHG.Booking ID', 'BookingID', 'COLUMN'
EXEC sp_rename 'SHG.Booking Date', 'Booking_Date', 'COLUMN'
EXEC sp_rename 'SHG.Arrival Date', 'Arrival_Date', 'COLUMN'
EXEC sp_rename 'SHG.Lead Time', 'Lead_Time', 'COLUMN'
EXEC sp_rename 'SHG.Distribution Channel', 'Distribution_Channel', 'COLUMN'
EXEC sp_rename 'SHG.Customer Type', 'Customer_Type', 'COLUMN'
EXEC sp_rename 'SHG.Deposit Type', 'Deposit_Type', 'COLUMN'
EXEC sp_rename 'SHG.Avg Daily Rate', 'Avg_Daily_Rate', 'COLUMN'
EXEC sp_rename 'SHG.Status Update', 'Status_Update', 'COLUMN'
EXEC sp_rename 'SHG.Revenue Loss', 'Revenue_Loss', 'COLUMN';


-- BOOKING BY YEAR


SELECT YEAR([Booking_Date]) AS BookingYear, COUNT([BookingID]) AS Total
FROM SHG
GROUP BY YEAR([Booking_Date])
ORDER BY BookingYear;



-- BOOKING BY MONTH FOR EACH YEAR


SELECT 
    YEAR([Booking_Date]) AS BookingYear, 
    DATENAME(month, [Booking_Date]) AS BookingMonth, 
    COUNT(*) AS BookingCount
FROM SHG
GROUP BY YEAR([Booking_Date]), DATENAME(month, [Booking_Date]), MONTH([Booking_Date])
ORDER BY BookingYear, MONTH(Booking_Date);


/* 2014 experienced the most bookings in october (2535)
	
	The top 5 booking for 2015 were:
	July (5196)
	October (4878)
	November (4254)
	December (4155)
	September (3740)

	The top 5 bookings for 2016 were:
	January (7654)
	February (6897)
	March (5429)
	November (5183)
	December (5013)

	The top 5 bookings for 2017 were:
	January (7869)
	February (5772)
	March (3609)
	May (2883)
	April (2736)
*/




SELECT TOP (1000) *
FROM SHG;



-- LEAD TIME VS BOOKING CHANNELS


SELECT [Distribution_Channel],
		AVG([Lead_Time]) AS Avg_Lead_Time
FROM SHG
GROUP BY [Distribution_Channel]
ORDER BY [Distribution_Channel];

/* It was observed that offline travel agent had the highest average
	lead time (135.59) and followed by Online travel agent (108.25)
*/


-- DISTRIBUTION CHANNEL VS AVERAGE DAILY RATE VS BOOKING COUNT


SELECT [Distribution_Channel],
		AVG([Avg_Daily_Rate]) AS Avg_Daily_Rate,
		COUNT(*) AS Booking_Count
FROM SHG
GROUP BY [Distribution_Channel]
ORDER BY 1;

/* The most bookings were from online travel agents (74,072)
	which also averages the highest daily rate of 108.57
*/



-- CUSTOMER SEGMENT VS DISTRIBUTION CHANNEL VS REVENUE LOSS FROM CANCELLATION



SELECT [Customer_Type],
		[Distribution_Channel],
		AVG([Revenue_Loss]) AS Average_Revenue_Loss
FROM SHG
WHERE [Cancelled (0/1)] = 1
GROUP BY [Customer_Type], [Distribution_Channel]
ORDER BY 1;

/* The most average revenue loss from contract and group customer type
	was seen from offline travel agents at $-720.44 and $-303.04 respectively

	The most average revenue loss from transient and transient-party customer type
	was seen from direct distribution channel at $-420.07 and $-305.85 respectively
*/


-- AVERAGE NIGHTS SPENT VS DISTRIBUTION CHANNEL OR CUSTOMER TYPE



SELECT [Distribution_Channel],
		AVG([Nights]) AS Avg_Length_of_Stay
FROM SHG
GROUP BY [Distribution_Channel]
ORDER BY 1;


/* The highest average length of stay is from Offline travel agents (3.92)
	and the least is from corporate (2.38)
*/


SELECT [Customer_Type],
		AVG([Nights]) AS Avg_Length_of_Stay
FROM SHG
GROUP BY [Customer_Type]
ORDER BY 1;


/* The highest average length of stay is from contract customer type (5.32)
	and the least is from group customer type (2.88)
*/




-- CUSTOMER TYPE VS DEPOSIT TYPE


SELECT [Customer_Type],
		[Deposit_Type],
		COUNT([Deposit_Type]) AS Total
FROM SHG
GROUP BY [Customer_Type], [Deposit_Type]
ORDER BY 1;


/* It can be observed that most customers prefer No deposit
	and followed by non-refundable
*/



--REVENUE CONTRIBUTION OF ONLINE TRAVEL AGENTS COMPARED TO OFFLINE TRAVEL AGENTS


WITH TotalRevenue AS (
    SELECT SUM(Revenue) AS total_revenue
    FROM SHG
	WHERE [Cancelled (0/1)] = 0
),
CategoryRevenue AS (
    SELECT 
        Distribution_Channel,
        SUM(Revenue) AS category_revenue
    FROM SHG
	WHERE Distribution_Channel IN ('Online Travel Agent', 'Offline Travel Agent') AND [Cancelled (0/1)] = 0
    GROUP BY Distribution_Channel
)
SELECT 
    cr.Distribution_Channel,
    cr.category_revenue,
    tr.total_revenue,
    ROUND((cr.category_revenue * 100.0 / tr.total_revenue), 2) AS percentage_contribution
FROM 
    CategoryRevenue cr,
    TotalRevenue tr
ORDER BY 
    cr.Distribution_Channel;


/* Offline agents = 21.64% revenue contribution
	Online agents = 58.53% revenue contribution
*/




-- CANCELLATION RATE AND REVENUE BETWEEN ONLINE AND OFFLINE TRAVEL AGENTS


WITH RevenueLoss AS (
	SELECT SUM(Revenue_Loss) AS Revenue_Loss,
		COUNT(*) AS CancelledTotal
	FROM SHG
	WHERE [Cancelled (0/1)] = 1
),
CategoryLoss AS (
	SELECT Distribution_Channel,
		SUM(Revenue_Loss) AS Dis_loss,
		COUNT(*) AS CancelledCategory
	FROM SHG
	WHERE Distribution_Channel IN ('Offline Travel Agent', 'Online Travel Agent') AND [Cancelled (0/1)] = 1
	GROUP BY Distribution_Channel
)
SELECT cl.Distribution_Channel,
	(cl.CancelledCategory * 100 / rl.CancelledTotal) AS Cancellation_Percentage,
	ROUND((cl.Dis_loss * 100 / rl.Revenue_Loss), 2) AS Loss_Contribution_Percentage
FROM RevenueLoss AS rl,
	CategoryLoss AS cl
ORDER BY cl.Distribution_Channel;

/* Offline agents = 18% cancellation and 8.46% revenue loss
	Online agents = 72% cancellation and 82.17% revenue loss
*/



