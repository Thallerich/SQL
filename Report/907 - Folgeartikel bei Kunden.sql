WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
),
FolgeKdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Haupstandort, FolgeArtikel.ArtikelNr AS [ArtikelNr neu], FolgeArtikel.ArtikelBez$LAN$ AS [Artikelbezeichnung neu], FolgeKdArtiStatus.StatusBez AS [Kundenartikel-Status Neu-Artikel], Artikel.ArtikelNr AS [ArtikelNr Alt], Artikel.ArtikelBez$LAN$ AS [Artikelbezeichnung Alt], KdArtiStatus.StatusBez AS [Kundenartikel-Status Alt-Artikel]
FROM KdArti
JOIN KdArtiStatus ON KdArti.Status = KdArtiStatus.Status
JOIN KdArti AS FolgeKdArti ON KdArti.FolgeKdArtiID = FolgeKdArti.ID
JOIN FolgeKdArtiStatus ON FolgeKdArti.Status = FolgeKdArtiStatus.Status
JOIN Artikel AS FolgeArtikel ON FolgeKdArti.ArtikelID = FolgeArtikel.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE KdArti.FolgeKdArtiID > 0
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND FolgeKdArti.Status = N'A'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.StandortID IN ($1$);