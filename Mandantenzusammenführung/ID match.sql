/* Matches two tables together */

USE OWS;

/*
DECLARE @TableID TABLE (
  ID_OWS int,
  ID_Woz int
);
*/

--INSERT INTO @TableID
SELECT Mitarbei.ID AS MitarbeiID, Mitarbei_Woz.ID AS MitarbeiID_Woz
FROM Mitarbei 
JOIN [ATENADVANTEX01\ADVANTEX].[Wozabal].[dbo].[Mitarbei] AS Mitarbei_Woz ON Mitarbei_Woz.UserName = Mitarbei.UserName
--WHERE Mitarbei_Woz.ID <> Mitarbei.ID
ORDER BY Mitarbei.ID;

/*

SELECT * FROM @TableID ORDER BY ID_Woz;

SELECT *
FROM Mitarbei
WHERE ID IN (SELECT ID_Woz FROM @TableID);

*/

/*
ALTER TABLE Mitarbei DISABLE TRIGGER LastModified_Mitarbei_UPDATE;

UPDATE Mitarbei SET Mitarbei.ID = TableID.ID_Woz
FROM Mitarbei
JOIN @TableID AS TableID ON TableID.ID_OWS = Mitarbei.ID;

ALTER TABLE Mitarbei ENABLE TRIGGER LastModified_Mitarbei_UPDATE;
*/