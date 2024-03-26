CREATE OR ALTER VIEW [sapbw].[V_BW_LAGERART] AS
SELECT 'ADV' AS [System], LagerArt.Lageart, LagerArt.LagerartBez
FROM Salesianer.dbo.LagerArt;