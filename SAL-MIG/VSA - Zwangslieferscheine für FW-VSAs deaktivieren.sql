UPDATE Vsa SET NichtImmerLS = 1
WHERE ID IN (
  SELECT Vsa.ID
  FROM Vsa
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
  JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  WHERE Bereich.Bereich = N'FW'
    AND StandBer.ProduktionID = (SELECT Standort.ID FROM Standort WHERE SuchCode = N'GRAZ')
    AND Vsa.NichtImmerLS = 0
);