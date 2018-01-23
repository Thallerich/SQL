DECLARE @TableID TABLE (
  ID_OWS int,
  ID_Woz int
);

INSERT INTO @TableID
SELECT Bereich.ID AS BereichID, Bereich_Woz.ID AS BereichID_Woz
FROM Bereich 
JOIN [ATENADVANTEX01\ADVANTEX].[Wozabal].[dbo].[Bereich] AS Bereich_Woz ON Bereich_Woz.Bereich = Bereich.Bereich
WHERE Bereich_Woz.ID <> Bereich.ID;

/*

SELECT * FROM @TableID ORDER BY ID_Woz;

SELECT *
FROM Bereich
WHERE ID IN (SELECT ID_Woz FROM @TableID);

*/

/*
ALTER TABLE Bereich DISABLE TRIGGER LastModified_Bereich_UPDATE;

UPDATE Bereich SET Bereich.ID = TableID.ID_Woz
FROM Bereich
JOIN @TableID AS TableID ON TableID.ID_OWS = Bereich.ID;

ALTER TABLE Bereich ENABLE TRIGGER LastModified_Bereich_UPDATE;
*/