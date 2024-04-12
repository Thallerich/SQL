CREATE OR ALTER VIEW [sapbw].[V_BW_LAGERART] AS
SELECT 'ADV' AS [System], LagerArt.Lagerart, LagerArt.LagerartBez
FROM Salesianer.dbo.LagerArt;