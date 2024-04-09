DROP TABLE IF EXISTS #SdcTeile;
GO

CREATE TABLE #SdcTeile (
  EinzHistID int,
  EinzTeilID int,
  SdcDevID int
);

GO

DECLARE @customer int = 10005133;

INSERT INTO #SdcTeile (EinzHistID, EinzTeilID, SdcDevID)
SELECT EinzHist.ID, EinzHist.EinzTeilID, SdcDev.ID
FROM EinzHist
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN StBerSDC ON StandBer.ID = StBerSDC.StandBerID
CROSS JOIN SdcDev
WHERE EinzHist.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @customer)
  AND SdcDev.ID != StBerSDC.SdcDevID
  AND SdcDev.IsTriggerDest = 1
  AND SdcDev.LinkedServerName IS NOT NULL
  AND StBerSDC.Modus = 0;

GO

INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT N'DELETE', N'EINZHIST', EinzHistID, N'THALST (ADS)', SdcDevID, 9021
FROM #SdcTeile;

GO

INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT N'DELETE', N'EINZTEIL', EinzTeilID, N'THALST (ADS)', SdcDevID, 9022
FROM #SdcTeile;

GO