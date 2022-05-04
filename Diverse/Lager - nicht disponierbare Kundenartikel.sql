DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
)
SELECT IIF(Firma.SuchCode = N'91', N'GASSER', Firma.SuchCode) AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].[ZonenCode] AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArtiStatus.StatusBez AS [Status Kundenartikel]
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
WHERE Artikel.ArtikelBez LIKE N'*%'
  AND KdArti.FolgeKdArtiID < 0
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Bereich.Traeger = 1
  AND (
    KdArti.Status != N'I'
    OR EXISTS (
      SELECT Teile.ID
      FROM Teile
      WHERE Teile.KdArtiID = KdArti.ID
        AND Teile.Status BETWEEN N'A' AND N'Q'
    )
  )
  AND (
    Bereich.Bereich = N'BK'
    OR EXISTS (
      SELECT TraeArti.ID
      FROM TraeArti
      WHERE TraeArti.KdArtiID = KdArti.ID
    )
  )
ORDER BY Firma, Geschäftsbereich, Vertriebszone, KdNr, ArtikelNr;