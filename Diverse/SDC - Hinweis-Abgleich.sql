/*
SELECT SdcDev.*
FROM Wozabal.dbo.SdcDev
WHERE SdcDev.IsTriggerDest = 1
ORDER BY SdcDev.ID ASC;
*/

DECLARE @SdcDevID int = 1;

INSERT INTO Wozabal.dbo.RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, [Priority])
SELECT IIF(SdcHinweis.ID IS NULL, N'INSERT', N'UPDATE') AS Typ, N'HINWEIS' AS TableName, HauptHinweis.ID AS TableID, N'SSMS' AS ApplicationID, @SdcDevID AS SdcDevID, 9000 AS [Priority]
FROM Wozabal.dbo.Hinweis AS HauptHinweis
JOIN Wozabal.dbo.Teile ON HauptHinweis.TeileID = Teile.ID
JOIN Wozabal.dbo.Vsa ON Teile.VsaID = Vsa.ID
JOIN Wozabal.dbo.KdArti ON Teile.KdArtiID = KdArti.ID
JOIN Wozabal.dbo.KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Wozabal.dbo.StandBer ON StandBer.BereichID = KdBer.BereichID AND StandBer.StandKonID = Vsa.StandKonID
LEFT OUTER JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_1.dbo.Hinweis AS SdcHinweis ON HauptHinweis.ID = SdcHinweis.ID
WHERE StandBer.SdcDevID = @SdcDevID
  AND (SdcHinweis.ID IS NULL OR HauptHinweis.Aktiv <> SdcHinweis.Aktiv OR HauptHinweis.StatusSDC <> SdcHinweis.StatusSDC)
  AND NOT EXISTS (
    SELECT RepQueue.*
    FROM Wozabal.dbo.RepQueue
    WHERE RepQueue.SdcDevID = @SdcDevID
      AND RepQueue.TableName = N'HINWEIS'
      AND RepQueue.TableID = HauptHinweis.ID
  );

GO

/*
SELECT SdcDev.Bez AS Sortieranlage, RepQueue.TableName, RepQueue.Typ, COUNT(RepQueue.Seq) AS [Anzahl Datensätze]
FROM Wozabal.dbo.RepQueue
JOIN Wozabal.dbo.SdcDev ON RepQueue.SdcDevID = SdcDev.ID
WHERE RepQueue.ApplicationID = N'SSMS'
GROUP BY SdcDev.Bez, RepQueue.TableName, RepQueue.Typ
ORDER BY SdcDev.Bez, RepQueue.Tablename, RepQueue.Typ;
*/