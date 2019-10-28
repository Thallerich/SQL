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

  --SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez
  UPDATE Kunden SET PatchArtID = (SELECT ID FROM PatchArt WHERE PatchArtBez = N'TT4 KR20 (Salesianer)')
  FROM Kunden
  JOIN Vsa ON Vsa.KundenID = Kunden.ID
  JOIN PatchArt ON Kunden.PatchArtID = PatchArt.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = 100
  JOIN Standort ON StandBer.ProduktionID = Standort.ID
  WHERE Standort.SuchCode = N'SMS'
    AND EXISTS (
      SELECT Traeger.*
      FROM Traeger
      WHERE Traeger.Status <> N'I'
        AND Traeger.VsaID = Vsa.ID
        AND Traeger.Altenheim = 0
    )
    AND PatchArt.PatchArtBez <> N'TT4 KR20 (Salesianer)';