SELECT Teile.Barcode, Status.StatusBez AS Teilestatus, Kunden.KdNr, Kunden.SuchCode, Standort.Bez AS Lagerstandort, Teile.PatchDatum, Teile.Eingang1, Teile.Ausgang1
--UPDATE Teile SET Barcode = RTRIM(Barcode) + N'*SAL'
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
WHERE Teile.Status IN (N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'T', N'U', N'W')
  AND Teile.Barcode LIKE N'2_________'
  AND Teile.PatchDatum <= N'2014-12-31'
  AND ISNULL(Teile.Eingang1, N'1980-01-01') <= N'2016-12-31';

SELECT Teile.Barcode, Status.StatusBez AS Teilestatus, Kunden.KdNr, Kunden.SuchCode, Standort.Bez AS Lagerstandort, Teile.PatchDatum, Teile.Eingang1, Teile.Ausgang1
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
WHERE Teile.Status NOT IN (N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'T', N'U', N'W', N'X')
  AND Teile.Barcode LIKE N'2_________';

/* #### erledigt 08.06.2018 ####
UPDATE Teile SET Barcode = RTRIM(Barcode) + N'*SAL'
FROM Teile
WHERE Teile.Status NOT IN (N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'T', N'U', N'W', N'X')
  AND Teile.Barcode LIKE N'2_________';
*/

-- TODO: Teile mit Status X extra behandeln - Lagerteile!
DECLARE @Lagerteile TABLE (
  TeileLagID int,
  TeileID int
);

INSERT INTO @Lagerteile
SELECT TeileLag.ID AS TeileLagID, Teile.ID AS TeileID --, TeileLag.Barcode, TeileLag.Status, TeileLag.ErstWoche, TeileLag.Ausdienst, Teile.PatchDatum, Teile.Eingang1, Teile.Ausgang1
FROM TeileLag
LEFT OUTER JOIN Teile ON Teile.Barcode = Teilelag.Barcode AND Teile.Status = N'X'
WHERE TeileLag.Barcode LIKE N'2_________'
  AND (Teile.PatchDatum < N'2018-04-01' OR Teile.PatchDatum IS NULL)
  AND TeileLag.Status <> N'R';

UPDATE TeileLag SET Barcode = RTRIM(Barcode) + N'*SAL' WHERE ID IN (SELECT DISTINCT TeileLagID FROM @Lagerteile WHERE TeileLagID IS NOT NULL);
UPDATE Teile SET Barcode = RTRIM(Barcode) + N'*SAL' WHERE ID IN (SELECT DISTINCT TeileID FROM @Lagerteile WHERE TeileID IS NOT NULL);