DROP TABLE IF EXISTS #CompareSdcSoll;
DROP TABLE IF EXISTS #CompareSdcJoin;

GO

SELECT Daten.*
INTO #CompareSdcSoll
FROM (
  SELECT DISTINCT EinzTeil.ID
  FROM Vsa, StandBer, StBerSdc, EinzTeil, EinzHist, KdArti, KdBer
  WHERE EinzHist.EinzTeilID = EinzTeil.ID
    AND Vsa.StandKonID = StandBer.StandKonID
    AND EinzHist.VsaID = Vsa.ID
    AND EinzHist.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID = StandBer.BereichID
    AND StandBer.ID = StBerSdc.StandBerID
    AND StBerSdc.Modus = 0
    AND StBerSdc.SdcDevID = 51
    AND EinzHist.Status >= N'M'
    AND EinzTeil.AltenheimModus = IIF(0 = 1, EinzTeil.AltenheimModus, 0)
  ) AS Daten;

SELECT Daten.*
INTO #CompareSdcJoin
FROM (
  SELECT COALESCE(t1.id, - 1) AS AdvID, COALESCE(t2.id, - 1) AS SdcID
  FROM #CompareSdcSoll AS t1
  FULL OUTER JOIN [SVATSAWRSQL1.sal.co.at].[Salesianer_SAWR].dbo.EinzTeil AS t2 ON (t1.id = t2.id)
) AS Daten;

SELECT * FROM #CompareSdcJoin WHERE AdvID > 0 AND SdcID < 0

INSERT INTO RepQueue ( Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
SELECT IIF(AdvID > -1, 'INSERT', 'DELETE') AS Typ, 'EINZTEIL' AS Tablename, IIF(AdvID > -1, AdvID, SdcID) AS TableID, N'THALST (9.70.02.16)' AS ApplicationID, 51 AS SdcDevID, 9999 AS Priority
FROM #CompareSdcJoin
WHERE AdvID > 0
  AND SdcID < 0
  AND NOT EXISTS (SELECT RepQueue.* FROM RepQueue WHERE RepQueue.TableID = #CompareSdcJoin.AdvID AND RepQueue.TableName = N'EINZTEIL' AND RepQueue.SdcDevID = 51);