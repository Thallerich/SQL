SELECT Kunden.KdNr,
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
  LiefArt.LiefArt AS Auslieferart,
  TraeArti.Menge AS [Max. Bestand],
  SUM(IIF(Teile.Status = N'Q', 1, 0)) AS Umlaufmenge,
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit) AS Stilllegung,
  IIF(ISNULL(Teile.Eingang1, N'1980-01-01') > ISNULL(Teile.Ausgang1, N'1980-01-01'), N'in Produktion', IIF(Teile.Eingang1 IS NULL AND Teile.Ausgang1 IS NULL, N'unbekannt', N'beim Kunden')) AS Verbleib,
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.IndienstDat AS [Letztes Einsatzdatum],
  Teile.RuecklaufG AS [Waschzyklen]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
WHERE Kunden.HoldingID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Vsa.ID IN ($3$)
  AND Teile.Status BETWEEN N'Q' AND N'W'
  AND Teile.Einzug IS NULL
GROUP BY Kunden.KdNr,
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
  LiefArt.LiefArt,
  TraeArti.Menge,
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit),
  IIF(ISNULL(Teile.Eingang1, N'1980-01-01') > ISNULL(Teile.Ausgang1, N'1980-01-01'), N'in Produktion', IIF(Teile.Eingang1 IS NULL AND Teile.Ausgang1 IS NULL, N'unbekannt', N'beim Kunden')),
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.IndienstDat,
  Teile.RuecklaufG
ORDER BY KdNr, VsaNr, Traeger, ArtikelNr, Groesse;