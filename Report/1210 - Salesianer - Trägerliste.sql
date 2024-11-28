WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$lan$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  VSA.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.Name2 AS [VSA-Adresszeile 2],
  Vsa.GebaeudeBez AS Gebäudebezeichnung,
  Abteil.Abteilung AS Stammkostenstelle,
  Abteil.Bez AS [Bezeichnung Stammkostenstelle],
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger AS [Träger-Nr],
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr AS Personalnummer,
  TraeAbteil.Abteilung AS [Abteilung Träger],
  TraeAbteil.Bez AS [Stammkostenstelle Träger],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  TraeArti.Menge AS [Max. Bestand],
  EinzHist.Barcode,
  CAST(IIF(EinzHist.Status > N'Q', 1, 0) AS bit) AS Stilllegung,
  Teilestatus.StatusBez AS Teilestatus,
  EinzHist.Eingang1,
  EinzHist.Ausgang1,
  EinzHist.IndienstDat AS [Letztes Einsatzdatum],
  EinzTeil.RuecklaufG AS [Waschzyklen],
  EinzTeil.AlterInfo AS [Alter in Wochen],
  KdArti.AfaWochen AS [AfA-Wochen],
  EinzTeil.AlterInfo - KdArti.AfaWochen AS [Differenz Alter zu AfA-Wochen]
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN Abteil AS TraeAbteil ON Traeger.AbteilID = TraeAbteil.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
WHERE Kunden.HoldingID IN ($1$)
  AND Kunden.ID IN ($2$)
  AND Vsa.ID IN ($3$)
  AND KdBer.BereichID IN ($4$)
  AND Kunden.StandortID IN ($5$)
  AND EinzTeil.AlterInfo >= $6$
  AND EinzHist.Status BETWEEN N'Q' AND N'W'
  AND EinzHist.Einzug IS NULL
  AND EinzHist.PoolFkt = 0
ORDER BY KdNr, VsaNr, Traeger, ArtikelNr, Groesse;