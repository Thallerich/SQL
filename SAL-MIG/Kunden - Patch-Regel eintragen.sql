SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, PatchArt.PatchArtBez AS PatchSchnittstelle
FROM Kunden
JOIN PatchArt ON Kunden.PatchArtID = PatchArt.ID
WHERE Kunden.StandortID IN (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'SMS')
  AND EXISTS (
    SELECT Teile.*
    FROM Teile
    JOIN Vsa ON Teile.VsaID = Vsa.ID
    WHERE Vsa.KundenID = Kunden.ID
  );

UPDATE Kunden SET PatchArtID = (SELECT PatchArt.ID FROM PatchArt WHERE PatchArt.PatchArtBez = N'TT4 KR20 (Salesianer)')
FROM Kunden
JOIN PatchArt ON Kunden.PatchArtID = PatchArt.ID
WHERE Kunden.StandortID IN (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'SMS')
  AND Kunden.PatchArtID < 0
  AND EXISTS (
    SELECT Teile.*
    FROM Teile
    JOIN Vsa ON Teile.VsaID = Vsa.ID
    WHERE Vsa.KundenID = Kunden.ID
  );