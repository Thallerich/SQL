WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT KdGf.KurzBez AS Geschäftsbereich,
  Kundenservice.Name AS [Kundenservice-Mitarbeiter],
  Holding.Holding,
  Holding.Bez AS [Holding-Bezeichnung],
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  VSA.VsaNr AS [VSA-Nummer],
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.Name2 AS [VSA-Adresszeile 2],
  VSa.GebaeudeBez AS [VSA-Gebäudebezeichnung],
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Schrank.SchrankNr AS Schrank,
  TraeFach.Fach,
  Traeger.Traeger AS [Träger-Nummer],
  Traeger.Titel,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr AS Personalnummer,
  Bereich.Bereich AS Produktberiech,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  TraeArti.Menge AS [Max. Bestand],
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit) AS Stilllegung,
  Teilestatus.StatusBez AS [Status des Teils],
  Teile.Eingang1 AS [letzter Eingang],
  Teile.Ausgang1 AS [letzter Ausgang],
  Teile.IndienstDat AS [Letztes Einsatzdatum],
  Teile.RuecklaufK AS [Waschzyklen aktueller Träger],
  Teile.RuecklaufG AS [Waschzyklen gesamt]
FROM Teile
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Mitarbei AS Kundenservice ON KdBer.ServiceID = Kundenservice.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
WHERE Teile.Status BETWEEN N'Q' AND N'W'
  AND Teile.Einzug IS NULL
  AND ISNULL(Teile.Eingang1, N'2099-12-31') > ISNULL(Teile.Ausgang1, N'1980-01-01')
  /* Aus ABS migrierte Teile filtern, die dort schon sehr lange nicht mehr gescannt wurden - diese haben keinen Scan-Datensatz */
  AND EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.TeileID = Teile.ID
  )
  AND Kunden.KdGfID IN ($1$)
  AND Bereich.ID IN ($2$)
  AND Vsa.StandKonID IN ($3$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Geschäftsbereich, Holding, KdNr, [VSA-Nummer], [Träger-Nummer], ArtikelNr, GroePo.Folge;