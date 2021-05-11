WITH Scan AS (
  SELECT Scans.TeileID, Scans.AnlageUserID_
  FROM Scans
  WHERE Scans.ActionsID = 4
  ),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS [VSA-Bezeichnung], Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Teile.AusdienstDat, CONVERT(nvarchar(60), NULL) AS AusdienstGrund, WegGrund.WeggrundBez$LAN$ AS Tauschgrund, Teile.RestwertInfo AS Restwert, Week.Woche AS ErstWoche, Teile.IndienstDat, Teile.Kostenlos, Teile.RuecklaufG AS [Anzahl Wäschen gesamt], Teile.RuecklaufK AS [Anzahl Wäschen Kunde], Mitarbei.Name AS [Mitarbeiter Austausch-Scan]
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN WegGrund ON Teile.WegGrundID = WegGrund.ID
LEFT JOIN Scan ON Scan.TeileID = Teile.ID
JOIN Mitarbei ON Scan.AnlageUserID_ = Mitarbei.ID
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE Teile.AltenheimModus = 0
  AND Kunden.ID = $ID$
  AND Teile.[Status] = N'S'

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS [VSA-Bezeichnung], Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Teile.AusdienstDat, Einsatz.EinsatzBez$LAN$ AS AusdienstGrund, WegGrund.WegGrundBez$LAN$ AS Tauschgrund, Teile.AusdRestw AS Restwert, Week.Woche AS Erstwoche, Teile.IndienstDat, Teile.Kostenlos, Teile.RuecklaufG AS [Anzahl Wäschen gesamt], Teile.RuecklaufK AS [Anzahl Wäschen Kunde], Mitarbei.Name AS [Mitarbeiter Austausch-Scan]
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Einsatz ON Teile.AusdienstGrund = Einsatz.EinsatzGrund
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN WegGrund ON Teile.WegGrundID = WegGrund.ID
LEFT JOIN Scan ON Scan.TeileID = Teile.ID
JOIN Mitarbei ON Scan.AnlageUserID_ = Mitarbei.ID
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE Teile.AltenheimModus = 0
  AND Teile.AusdienstGrund IN ('A', 'a', 'B', 'b', 'C', 'c')
  AND Teile.AusdienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Teile.[Status] > N'S'
  AND Kunden.ID = $ID$;