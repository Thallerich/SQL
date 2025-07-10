SELECT Firma.Bez AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, LsKo.LsNr, LsKo.Datum AS Lieferdatum, OPEtiKo.EtiNr AS [Set-Seriennummer]
FROM OPEtiKo
JOIN LsPo ON OPEtiKo.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
WHERE LsKo.Datum >= DATEADD(month, -3, GETDATE())
  AND OPEtiKo.ProduktionID = (SELECT ID FROM Standort WHERE Bez = N'MC Lenzing')
  AND OPEtiKo.LsPoID > 0;

GO