--SELECT Teile.ID AS TeileID, Teile.Barcode, Teile.Eingang1, Teile.Ausgang1, Teile.Status, Teile.Einzug
UPDATE Teile SET Einzug = ISNULL(Eingang1, N'1980-01-01')
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Teile.Status = N'W'
  AND Teile.AltenheimModus = 0
  AND Teile.Einzug IS NULL
  AND ((Teile.Eingang1 > ISNULL(Teile.Ausgang1, N'1980-01-01')) OR (Teile.Eingang1 IS NULL AND Teile.Ausgang1 IS NULL))
  AND Kunden.KdGFID = 2
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.StandortID IN (
    SELECT ID
    FROM Standort
    WHERE SuchCode LIKE N'WOE%'
      OR SuchCode LIKE N'WOL%'
  );