USE [Reporting]
GO

/****** Object:  StoredProcedure [dbo].[JenrailReadResults]    Script Date: 10.03.2022 16:59:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[JenrailReadResults]
    @startDate Datetime,
    @endDate Datetime
AS 
BEGIN    

	SET XACT_ABORT ON
	SET NOCOUNT ON

	SELECT Stations.Station, 
		   ISNULL(total.[Total Requests], 0) as 'Total Requests', 
		   ISNULL(db.MultiRead, 0) as 'Double read', 
		   ISNULL(nr.NoRead, 0) as 'No read',
		   ISNULL(prevStatement.DoubleRead, 0) - ISNULL(db.MultiRead, 0) as 'Nicht codiert',
		   ISNULL(prevStatement.NoRead, 0) - ISNULL(nr.NoRead, 0) as 'Nicht in Schablone', 
		   ISNULL((CAST(nr.NoRead as numeric(9,4)) *100 / [total].[Total Requests]), 0) as '% no read', 
		   ISNULL((CAST( db.MultiRead as numeric(9,4)) *100 / [total].[Total Requests]), 0) as '% double read', 
		   ISNULL((CAST((ISNULL(prevStatement.DoubleRead, 0) - ISNULL(db.MultiRead, 0)) as numeric(9,4)) *100 / [total].[Total Requests]), 0) as '% nicht codiert',
		   ISNULL((CAST((ISNULL(prevStatement.NoRead, 0) - ISNULL(nr.NoRead, 0)) as numeric(9,4)) *100 / [total].[Total Requests]), 0) as '% nicht in Schablone',
		   ISNULL(prevStatement.[Summe Windeln/Handschuhe], 0) as 'Summe Windeln/Handschuhe'
	FROM (
		SELECT '31' as Station 
		UNION SELECT '32' 
		UNION SELECT '33'
		UNION SELECT '34' 
		UNION SELECT '35'
		UNION SELECT '36' 
		UNION SELECT '37'
		UNION SELECT '38'
	) as Stations
	LEFT JOIN (
		SELECT total.StationNumber, SUM([Total Requests]) as 'Total Requests' FROM 
		(
			SELECT total.StationNumber, COUNT(*) as 'Total Requests' 
			FROM  JenrailLog.dbo.DestinationResponseLog total
			WHERE LogDate > @startDate
			  AND LogDate < @endDate
			GROUP BY total.StationNumber
			UNION ALL 
			SELECT total.StationNumber, COUNT(*) as 'Total Requests' 
			FROM  BackupLog.dbo.Jenrail_DestinationResponseLog total
			WHERE LogDate > @startDate
			  AND LogDate < @endDate 
			GROUP BY total.StationNumber
		) as total
		GROUP BY total.StationNumber
	) as total ON total.StationNumber = Stations.Station
	LEFT JOIN (
		SELECT db.Station, SUM(db.MultiRead) as MultiRead
		FROM (
			SELECT COUNT(*) as MultiRead,
				   SUBSTRING(Message, LEN('Multiple articles read at station ') + 2, 2) as Station
			FROM  JenrailLog.dbo.[ErrorLog]
			WHERE LogDate > @startDate
			  AND LogDate <  @endDate
			  AND Message LIKE 'Multiple articles read at station %! Read count: %'
			GROUP BY SUBSTRING(Message, LEN('Multiple articles read at station ') + 2, 2)
			UNION ALL
			SELECT COUNT(*) as MultiRead,
				   SUBSTRING(Message, LEN('Multiple articles read at station ') + 2, 2) as Station
			FROM  BackupLog.dbo.Jenrail_ErrorLog
			WHERE LogDate > @startDate
			  AND LogDate <  @endDate
			  AND Message LIKE 'Multiple articles read at station %! Read count: %'
			GROUP BY SUBSTRING(Message, LEN('Multiple articles read at station ') + 2, 2)
		) as db
		GROUP BY db.Station
	) as db ON Stations.Station = db.Station
	LEFT JOIN (
		SELECT nr.Station, SUM(nr.NoRead) as NoRead
		FROM (
		--
			SELECT COUNT(*) as NoRead, 
				   SUBSTRING(Message, LEN('No article read at station ') + 2, 2) as Station
			FROM  JenrailLog.dbo.[ErrorLog]
			WHERE LogDate > @startDate
			  AND LogDate <  @endDate
			  AND Message LIKE 'No article read at station %!'
			GROUP BY SUBSTRING(Message, LEN('No article read at station ') + 2, 2)
			UNION ALL 
			SELECT COUNT(*) as NoRead, 
				   SUBSTRING(Message, LEN('No article read at station ') + 2, 2) as Station
			FROM  BackupLog.dbo.Jenrail_ErrorLog
			WHERE LogDate > @startDate
			  AND LogDate <  @endDate
			  AND Message LIKE 'No article read at station %!'
			GROUP BY SUBSTRING(Message, LEN('No article read at station ') + 2, 2)
			UNION ALL
			SELECT COUNT(*) as NoRead, 
				   SUBSTRING(Message, LEN('Reading not started at station ') + 2, 2) as Station
			FROM  JenrailLog.dbo.[ErrorLog]
			WHERE LogDate > @startDate
			  AND LogDate <  @endDate
			  AND Message LIKE 'Reading not started at station %!'
			GROUP BY SUBSTRING(Message, LEN('Reading not started at station ') + 2, 2)
			UNION ALL
			SELECT COUNT(*) as NoRead, 
				   SUBSTRING(Message, LEN('Reading not started at station ') + 2, 2) as Station
			FROM  BackupLog.dbo.Jenrail_ErrorLog
			WHERE LogDate > @startDate
			  AND LogDate <  @endDate
			  AND Message LIKE 'Reading not started at station %!'
			GROUP BY SUBSTRING(Message, LEN('Reading not started at station ') + 2, 2)
		) as nr
		GROUP BY nr.Station
	) as nr ON Stations.Station = nr.Station
	LEFT JOIN (
		SELECT total.*,
		ISNULL(noRead.NoRead, 0) as NoRead, ISNULL(doubleRead.DoubleRead, 0) as DoubleRead, 
		ISNULL((CAST(noRead.NoRead as numeric(9,4)) *100 / [Total Requests]), 0) as PercentNoRead, 
		ISNULL((CAST( doubleRead.DoubleRead as numeric(9,4)) *100 / [Total Requests]), 0) as PercentDoubleRead,
		ISNULL(x.cnt, 0) as 'Summe Windeln/Handschuhe'
		FROM 
		(
			SELECT total.StationNumber, SUM([Total Requests]) as 'Total Requests' FROM 
			(
				SELECT total.StationNumber, COUNT(*) as 'Total Requests' 
				FROM  JenrailLog.dbo.DestinationResponseLog total
				WHERE LogDate > @startDate
				  AND LogDate < @endDate
				GROUP BY total.StationNumber
				UNION ALL 
				SELECT total.StationNumber, COUNT(*) as 'Total Requests' 
				FROM  BackupLog.dbo.Jenrail_DestinationResponseLog total
				WHERE LogDate > @startDate
				  AND LogDate < @endDate 
				GROUP BY total.StationNumber
			) as total
			GROUP BY total.StationNumber
		) as total 
		LEFT JOIN 
		(
			SELECT StationNumber,  SUM([NoRead]) as 'NoRead'  FROM (
				SELECT StationNumber,  COUNT(*) as 'NoRead' 
				FROM  JenrailLog.dbo.DestinationResponseLog noRead
				WHERE CategoryNumber = 0 
					AND LogDate > @startDate
					AND LogDate < @endDate
				GROUP BY StationNumber
				UNION ALL 
				SELECT StationNumber,  COUNT(*) as 'NoRead' 
				FROM  BackupLog.dbo.Jenrail_DestinationResponseLog noRead
				WHERE CategoryNumber = 0 
					AND LogDate > @startDate
					AND LogDate < @endDate
				GROUP BY StationNumber
			) as noRead
			GROUP BY StationNumber
		) as noRead ON total.StationNumber = noRead.StationNumber 
		LEFT JOIN 
		(
			SELECT StationNumber, SUM([DoubleRead]) as 'DoubleRead'  FROM (
				SELECT StationNumber, COUNT(*) as 'DoubleRead' 
				FROM  JenrailLog.dbo.DestinationResponseLog noRead
				WHERE CategoryNumber = 9999 
					AND LogDate > @startDate
					AND LogDate < @endDate
				GROUP BY StationNumber
				UNION ALL 
				SELECT StationNumber, COUNT(*) as 'DoubleRead' 
				FROM  BackupLog.dbo.Jenrail_DestinationResponseLog noRead
				WHERE CategoryNumber = 9999 
					AND LogDate > @startDate
					AND LogDate < @endDate
				GROUP BY StationNumber
			) as doubleRead 
			GROUP BY StationNumber
		) as doubleRead ON total.StationNumber = doubleRead.StationNumber 
		LEFT JOIN (
			SELECT rcl.RequestPlaceID, COUNT(*) as 'cnt' FROM  JenrailLog.dbo.RecordedChipLog rcl
			WHERE rcl.EanNumber IN (
				'1012600130109', --Waschhandschuh gelb (NÖ)
				'1112600130106', --Waschhandschuh gelb inkl. Chip (NÖ)
				'1112600200014', --Waschhandschuh inkl. Chip
				'1112600220012', --Waschhandschuh Premium weiss inkl. Chip
				'1112608259250', --Waschhandschuh mint (NÖ) inkl. Chip
				'1144280100018', --Windeln gebügelt inkl. Chip
				'1144280200015', --Windel ungebügelt inkl. Chip
				'1144280300029'  --Windeln bedruckt inkl. Chip (NÖ)
			)
			  AND rcl.LogDate > @startDate
			  AND rcl.LogDate < @endDate
			GROUP BY rcl.RequestPlaceID
		) as x ON x.RequestPlaceID = total.StationNumber
	) as prevStatement ON Stations.Station = prevStatement.StationNumber
	ORDER BY 1

END

GO





USE [LaundryAutomation]
GO

/****** Object:  StoredProcedure [dbo].[GetEuroSortIgnoredHexCodes]    Script Date: 10.03.2022 17:05:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetEuroSortIgnoredHexCodes]
AS 
BEGIN

SELECT Sgtin96HexCode FROM EurosortLog.dbo.RecordedChipLog rcl
WHERE rcl.LogDate > DATEADD(minute, -10, GETDATE())
GROUP BY rcl.Sgtin96HexCode
HAVING COUNT(*) > 30
ORDER BY 1 

END

GO






USE [LaundryAutomationTest]
GO

/****** Object:  StoredProcedure [dbo].[GetEuroSortIgnoredHexCodes]    Script Date: 10.03.2022 17:07:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetEuroSortIgnoredHexCodes]
AS 
BEGIN

--SELECT Sgtin96HexCode FROM EurosortLog.dbo.RecordedChipLog rcl
--WHERE rcl.LogDate > DATEADD(minute, -10, GETDATE())
--GROUP BY rcl.Sgtin96HexCode
--HAVING COUNT(*) > 30
--ORDER BY 1 

-- Not needed here
SELECT '' as Sgtin96HexCode
WHERE 1 = 2

END


GO




