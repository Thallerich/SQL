WITH AustauschScan AS (
  SELECT Scans.EinzteilID TeileID, MAX(Scans.ID) AS ScanID
  FROM Scans
  WHERE Scans.ActionsID = 4
    AND Scans.EinzteilID > 0
  GROUP BY Scans.EinzteilID
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'EINZHIST')
)

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde
, Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS [VSA-Bezeichnung]
, Einzteil.Code, Teilestatus.StatusBez AS Teilestatus
, Artikel.ArtikelNr, Artikel.ArtikelBez/*$LAN$*/ AS Artikelbezeichnung
, ArtGroe.Groesse AS Größe
, Einzhist.AusdienstDat
, CONVERT(nvarchar(60), NULL) AS AusdienstGrund
, WegGrund.WeggrundBez$LAN$ AS Tauschgrund
, Einzteil.RestwertInfo AS Restwert
, Week.Woche AS ErstWoche
, einzhist.IndienstDat, einzhist.Kostenlos, Einzteil.RuecklaufG AS [Anzahl Wäschen gesamt], Einzhist.RuecklaufK AS [Anzahl Wäschen Kunde]
, Mitarbei.Name AS [Mitarbeiter Austausch-Scan]
FROM EINZTEIL
JOIN EINZHIST on EINZTEIL.CurrEinzHistID = EINZHIST.ID
JOIN KUNDEN on EINZHIST.KundenID = KUNDEN.ID
JOIN VSA on einzhist.VsaID = vsa.ID
JOIN ARTIKEL on EINZHIST.ArtikelID = Artikel.ID
JOIN ARTGROE on EINZHIST.ArtGroeID = ArtGroe.ID
JOIN Teilestatus on EINZHIST.[Status] = Teilestatus.[Status]
JOIN WegGrund ON Einzteil.WegGrundID = WegGrund.ID
LEFT JOIN AustauschScan on AustauschScan.TeileID = EINZTEIL.ID
LEFT JOIN Scans on AustauschScan.ScanID = Scans.ID
LEFT JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
JOIN Week ON DATEADD(day, Einzteil.AnzTageImLager, Einzteil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE Einzteil.AltenheimModus = 0
  AND Kunden.ID = $ID$
  AND einzhist.[Status] = N'S'
  AND Kunden.HoldingID in ($2$)

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde
, Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS [VSA-Bezeichnung], Einzteil.code, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse
, Einzhist.AusdienstDat, Einsatz.EinsatzBez$LAN$ AS AusdienstGrund, WegGrund.WegGrundBez/*$LAN$*/ AS Tauschgrund, Einzhist.AusdRestw AS Restwert, Week.Woche AS Erstwoche
, Einzhist.IndienstDat, einzhist.Kostenlos, einzteil.RuecklaufG AS [Anzahl Wäschen gesamt], einzhist.RuecklaufK AS [Anzahl Wäschen Kunde], Mitarbei.Name AS [Mitarbeiter Austausch-Scan]
FROM EINZTEIL
JOIN EINZHIST on EINZTEIL.CurrEinzHistID = EINZHIST.ID
JOIN KUNDEN on EINZHIST.KundenID = KUNDEN.ID
JOIN Einsatz ON einzhist.ausdienstGrund = Einsatz.EinsatzGrund
JOIN VSA on einzhist.VsaID = vsa.ID
JOIN ARTIKEL on EINZHIST.ArtikelID = Artikel.ID
JOIN ARTGROE on EINZHIST.ArtGroeID = ArtGroe.ID
JOIN Teilestatus on EINZHIST.[Status] = Teilestatus.[Status]
JOIN WegGrund ON Einzteil.WegGrundID = WegGrund.ID
LEFT JOIN AustauschScan on AustauschScan.TeileID = EINZTEIL.ID
LEFT JOIN Scans on AustauschScan.ScanID = Scans.ID
LEFT JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
JOIN Week ON DATEADD(day, Einzteil.AnzTageImLager, Einzteil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE einzteil.AltenheimModus = 0
--  AND einzhist.ausdienstGrund IN ('A', 'a', 'B', 'b', 'C', 'c')
  AND EinzHist.AusdienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
--  AND einzhist.[Status] = N'S'
  AND Kunden.ID = $ID$
  AND Kunden.HoldingID in ($2$)