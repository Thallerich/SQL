--CREATE OR ALTER VIEW [sapbw].[V_BW_RPoType] AS
SELECT CAST(RPoType.ID AS nvarchar) AS RPoTypeID, RPoType.RPoTypeBez
FROM Salesianer.dbo.RPoType;