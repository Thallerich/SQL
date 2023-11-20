UPDATE Sortier SET TourText = N'[TOUREXAKT][STOPGROUP]'
WHERE ID IN (
  SELECT Sortier.ID AS SortierID
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN Vsa ON VsaTour.VsaID = Vsa.ID
  JOIN Sortier ON Vsa.SortierID = Sortier.ID
  JOIN StandKon ON Vsa.StandKonID = StandKon.ID
  WHERE Touren.Tour LIKE N'1-_24-%'
    AND EXISTS (
      SELECT StBerSDC.*
      FROM StBerSDC
      JOIN StandBer ON StBerSDC.StandBerID = StandBer.ID
      WHERE StandBer.StandKonID = StandKon.ID
    )
);