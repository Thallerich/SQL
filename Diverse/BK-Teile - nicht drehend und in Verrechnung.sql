WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, KdArti.LeasingPreis AS Mietpreis, Teilestatus.StatusBez AS [Status des Teils], Teile.Ausgang1 AS [Letzte Auslieferung]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
WHERE Teile.Status BETWEEN N'Q' AND N'W'
  AND Teile.Ausdienst IS NULL
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND KdArti.LeasingPreis <> 0
  AND Teile.Ausgang1 < N'2016-01-01';