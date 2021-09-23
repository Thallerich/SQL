SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Hauptstandort, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Eigentum.EigentumBez
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
WHERE Firma.SuchCode = N'FA14'
  AND (Artikel.ArtikelNr LIKE N'EW%' OR Artikel.ArtikelNr LIKE N'SW%' OR Artikel.ArtikelNr LIKE N'SC%' OR Artikel.ArtikelNr LIKE N'SV%')
  AND Artikel.ArtikelNr NOT LIKE N'SCHR%'
  AND Eigentum.EigentumBez != N'Kundeneigentum'
  AND Kunden.KdNr != 99700
ORDER BY KdNr, ArtikelNr;