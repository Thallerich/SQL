WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
),
LsVerwend AS (
  SELECT MAX(LsKo.Datum) AS Lieferdatum, LsPo.KdArtiID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  GROUP BY LsPo.KdArtiID
),
LsVerwendJahr AS (
  SELECT SUM(LsPo.Menge) AS Menge, LsPo.KdArtiID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum > DATEADD(year, -1, GETDATE())
  GROUP BY LsPo.KdArtiID
)
SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Hauptstandort, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArtiStatus.StatusBez AS Kundenartikelstatus, VertragWae.IsoCode AS Vertragswährung, CAST(KdArti.WaschPreis AS money) AS Bearbeitungspreis, LsVerwend.Lieferdatum AS [Datum letzter Lieferschein], ISNULL(CAST(LsVerwendJahr.Menge AS int), 0) AS [Menge fakturiert im letzten Jahr]
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
JOIN Wae AS VertragWae ON Kunden.VertragWaeID = VertragWae.ID
LEFT JOIN LsVerwend ON LsVerwend.KdArtiID = KdArti.ID
LEFT JOIN LsVerwendJahr ON LsVerwendJahr.KdArtiID = KdArti.ID
WHERE (UPPER(Artikel.ArtikelBez) LIKE N'%ZUSTELL%' OR UPPER(Artikel.ArtikelBez) LIKE N'%ANFAHR%' OR Artikel.ArtikelNr = N'ZUS')
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A';