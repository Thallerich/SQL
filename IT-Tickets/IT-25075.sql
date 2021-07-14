WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Teile.Eingang1 AS [Letzter Eingang], Teile.Ausgang1 AS [Letzter Ausgang], Teile.RuecklaufK AS [Anzahl Wäschen beim Kunden], Teile.RuecklaufG AS [Anzahl Wäschen Gesamt], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Teile
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
WHERE Bereich.Bereich = N'RR'
  AND Teile.Eingang1 >= CAST(DATEADD(month, -3, GETDATE()) AS date);