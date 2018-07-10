DECLARE @SdcDevID int = 3;

INSERT INTO Wozabal.dbo.RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, [Priority])
SELECT N'UPDATE' AS Typ, N'TEILE' AS TableName, HauptTeile.ID AS TableID, N'SSMS (8.30.09.03)' AS ApplicationID, @SdcDevID AS SdcDevID, 9000 AS [Priority]
--SELECT HauptTeile.ID AS WH_TeileID, SdcTeile.ID AS SDC_TeileID, HauptTeile.Barcode AS WH_Barcode, SdcTeile.Barcode AS SDC_Barcode, HauptTeile.Status AS WH_Status, SdcTeile.Status AS SDC_Status
FROM Wozabal.dbo.Teile AS HauptTeile
JOIN Wozabal.dbo.Vsa ON HauptTeile.VsaID = Vsa.ID
JOIN Wozabal.dbo.KdArti ON HauptTeile.KdArtiID = KdArti.ID
JOIN Wozabal.dbo.KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Wozabal.dbo.StandBer ON StandBer.BereichID = KdBer.BereichID AND StandBer.StandKonID = Vsa.StandKonID
LEFT OUTER JOIN [SRVATENSDC01.WOZABAL.INT\ADVANTEX].Wozabal_Enns_2.dbo.Teile AS SdcTeile ON HauptTeile.ID = SdcTeile.ID
WHERE StandBer.SdcDevID = @SdcDevID
  AND HauptTeile.Status < N'X'
  AND (SdcTeile.ID IS NULL OR HauptTeile.Barcode <> SdcTeile.Barcode OR HauptTeile.Status <> SdcTeile.Status)
  AND NOT EXISTS (
    SELECT RepQueue.*
    FROM Wozabal.dbo.RepQueue
    WHERE RepQueue.SdcDevID = @SdcDevID
      AND RepQueue.TableName = N'TEILE'
      AND RepQueue.TableID = HauptTeile.ID
  );

GO