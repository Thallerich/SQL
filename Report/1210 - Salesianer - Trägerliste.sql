WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  VSA.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  TraeArti.Menge AS [Max. Bestand],
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit) AS Stilllegung,
  Teilestatus.StatusBez AS Teilestatus,
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.IndienstDat AS [Letztes Einsatzdatum],
  Teile.RuecklaufG AS [Waschzyklen]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
WHERE Kunden.HoldingID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Vsa.ID IN ($3$)
  AND Teile.Status BETWEEN N'Q' AND N'W'
  AND Teile.Einzug IS NULL
GROUP BY Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  ArtGroe.Groesse,
  KdArti.Variante,
  KdArti.VariantBez,
  TraeArti.Menge,
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit),
  Teilestatus.Statusbez,
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.IndienstDat,
  Teile.RuecklaufG
ORDER BY KdNr, VsaNr, Traeger, ArtikelNr, Groesse;