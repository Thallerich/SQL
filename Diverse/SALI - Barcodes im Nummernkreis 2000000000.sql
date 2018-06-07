SELECT Teile.Barcode, Status.StatusBez AS Teilestatus, Kunden.KdNr, Kunden.SuchCode, Standort.Bez AS Lagerstandort, Teile.PatchDatum, Teile.Eingang1, Teile.Ausgang1
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
WHERE Teile.Status IN (N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'T', N'U', N'W')
  AND Teile.Barcode LIKE N'2_________';

SELECT Teile.Barcode, Status.StatusBez AS Teilestatus, Kunden.KdNr, Kunden.SuchCode, Standort.Bez AS Lagerstandort, Teile.PatchDatum, Teile.Eingang1, Teile.Ausgang1
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
WHERE Teile.Status NOT IN (N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'T', N'U', N'W')
  AND Teile.Barcode LIKE N'2_________';

SELECT Teile.*
--UPDATE Teile SET Barcode = RTRIM(Barcode) + N'*SAL'
FROM Teile
WHERE Teile.Status NOT IN (N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'T', N'U', N'W')
  AND Teile.Barcode LIKE N'2_________';

SELECT TeileLag.*
FROM TeileLag
--UPDATE TeileLag SET Barcode = RTRIM(Barcode) + N'*SAL'
WHERE TeileLag.Barcode LIKE N'2_________';