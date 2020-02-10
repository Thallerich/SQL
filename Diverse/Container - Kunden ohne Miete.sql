SELECT Kunden.KdNr, Kunden.SuchCode, KdGf.KurzBez AS SGF, Standort.Bez AS Hauptstandort
FROM Kunden
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND KdGf.KurzBez = N'GAST'
  AND EXISTS (
    SELECT Vsa.*
    FROM Vsa
    WHERE Vsa.KundenID = Kunden.ID
      AND Vsa.StandKonID = (SELECT ID FROM StandKon WHERE StandKonBez = N'FW: Lenzing Hotel')
      AND Vsa.Status = N'A'
  )
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE Artikel.ArtikelNr = N'CONTMIET'
      AND KdArti.KundenID = Kunden.ID
  );