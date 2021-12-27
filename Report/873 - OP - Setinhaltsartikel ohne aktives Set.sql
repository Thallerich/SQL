WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, Bereich.BereichBez$LAN$ AS Produktbereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe
FROM Artikel
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE ArtGru.SetArtikel = 1
  AND Artikel.Status < N'I'
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
    WHERE OPSets.Artikel1ID = Artikel.ID
      AND SetArtikel.Status < N'I'
  )
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
    WHERE OPSets.Artikel2ID = Artikel.ID
      AND SetArtikel.Status < N'I'
  )
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
    WHERE OPSets.Artikel3ID = Artikel.ID
      AND SetArtikel.Status < N'I'
  )
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
    WHERE OPSets.Artikel4ID = Artikel.ID
      AND SetArtikel.Status < N'I'
  )
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    JOIN Artikel AS SetArtikel ON OPSets.ArtikelID = SetArtikel.ID
    WHERE OPSets.Artikel5ID = Artikel.ID
      AND SetArtikel.Status < N'I'
  );