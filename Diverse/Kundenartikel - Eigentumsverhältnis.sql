WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT Firma.SuchCode AS Firma, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, KdArtiStatus.StatusBez AS Kundenartikelstatus, Eigentum.EigentumBez AS Eigentumsverhältnis
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND (Artikel.ArtikelNr LIKE N'SW%' OR Artikel.ArtikelNr LIKE N'SC%' OR Artikel.ArtikelNr LIKE N'SV%' OR Artikel.ArtikelNr LIKE N'SR%')
  AND Artikel.ArtikelNr NOT LIKE N'SCHR%'
  AND Eigentum.EigentumBez != N'Kundeneigentum';