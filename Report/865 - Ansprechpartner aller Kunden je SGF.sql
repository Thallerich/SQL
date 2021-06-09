SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kundenstichwort, ABC.ABCBez AS [ABC-Klasse], Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.[Position], Sachbear.Telefon, Sachbear.Telefax, Sachbear.Mobil, Sachbear.eMail
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN ABC ON Kunden.AbcID = Abc.ID
LEFT OUTER JOIN Sachbear ON Sachbear.TableID = Kunden.ID AND Sachbear.TableName = N'KUNDEN'
WHERE KdGf.ID IN ($1$)
  AND Kunden.Status = N'A'
  AND Sachbear.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY SGF, Kunden.KdNr;