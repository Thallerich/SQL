USE Salesianer;
GO

UPDATE Vsa SET NichtImmerLS = 1
FROM Vsa
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Standort.SuchCode = N'SA22'
  AND NOT EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.Bereich = N'BK'
      AND VsaTour.VsaID = Vsa.ID
  )
  AND Vsa.NichtImmerLS = 0;

GO