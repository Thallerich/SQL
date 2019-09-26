WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
),
MedArtikel AS (
  SELECT DISTINCT KdArti.ArtikelID
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGFID = KdGf.ID
  WHERE KdGf.KurzBez = N'MED'
    AND Kunden.FirmaID IN ($1$)
    AND Kunden.AdrArtID = 1
    AND Kunden.Status = N'A'
),
GastArtikel AS (
  SELECT DISTINCT KdArti.ArtikelID
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGFID = KdGf.ID
  WHERE KdGf.KurzBez = N'GAST'
    AND Kunden.FirmaID IN ($1$)
    AND Kunden.AdrArtID = 1
    AND Kunden.Status = N'A'
),
JobArtikel AS (
  SELECT DISTINCT KdArti.ArtikelID
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGFID = KdGf.ID
  WHERE KdGf.KurzBez = N'JOB'
    AND Kunden.FirmaID IN ($1$)
    AND Kunden.AdrArtID = 1
    AND Kunden.Status = N'A'
),
Lagerbestand AS (
  SELECT Bestand.ArtGroeID, Standort.Bez AS Lagerstandort, SUM(Bestand.Bestand) AS Bestand, LagerArt.Neuwertig
  FROM Bestand
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  WHERE LagerArt.IstAnfLager = 0
    AND Standort.FirmaID IN ($1$)
  GROUP BY Bestand.ArtGroeID, Standort.Bez, LagerArt.Neuwertig
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, ArtGroe.Groesse AS [Größe], Lagerbestand.Lagerstandort, Lagerbestand.Neuwertig AS [Neuware?], ISNULL(Lagerbestand.Bestand, 0) AS Lagerbestand, CAST(IIF(MedArtikel.ArtikelID IS NULL, 0, 1) AS bit) AS [Ist MED-Artikel?], CAST(IIF(GastArtikel.ArtikelID IS NULL, 0, 1) AS bit) AS [Ist GAST-Artikel?], CAST(IIF(JobArtikel.ArtikelID IS NULL, 0, 1) AS bit) AS [Ist JOB-Artikel?]
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
LEFT OUTER JOIN Lagerbestand ON Lagerbestand.ArtGroeID = ArtGroe.ID
LEFT OUTER JOIN MedArtikel ON MedArtikel.ArtikelID = Artikel.ID
LEFT OUTER JOIN GastArtikel ON GastArtikel.ArtikelID = Artikel.ID
LEFT OUTER JOIN JobArtikel ON JobArtikel.ArtikelID = Artikel.ID
WHERE Artikel.ID > 0
  AND Artikel.ArtiTypeID = 1
  AND (
      ($2$ = 1 AND MedArtikel.ArtikelID IS NOT NULL)
    OR
      ($3$ = 1 AND GastArtikel.ArtikelID IS NOT NULL)
    OR
      ($4$ = 1 AND JobArtikel.ArtikelID IS NOT NULL)
    OR
      ($2$ = 0 AND $3$ = 0 AND $4$ = 0)
  )
  AND (
      ($5$ = 1 AND ISNULL(Lagerbestand.Bestand, 0) <> 0)
    OR
      ($5$ = 0)
  );