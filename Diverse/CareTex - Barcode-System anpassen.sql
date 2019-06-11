WITH BewTeile AS (
  SELECT Teile.ID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Teile.AltenheimModus = 1
    AND LEN(Teile.Barcode) = 11
    AND LEFT(Teile.Barcode, 3) = N'999'
    AND Vsa.Status = N'A'
    AND Kunden.Status = N'A'
    AND Vsa.StandKonID = 59
)
UPDATE Teile SET Barcode = RIGHT(Barcode, 8)
WHERE ID IN (SELECT ID FROM BewTeile)
  AND NOT EXISTS (
    SELECT x.*
    FROM Teile AS x
    WHERE x.Barcode = RIGHT(Teile.Barcode, 8)
  );