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
SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [VSA-Nr.],
  Vsa.Bez AS [VSA-Bezeichnung],
  Einzteil.Code,
  Teilestatus.StatusBez AS Teilestatus,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.AusdienstDat AS Außerdienststellungsdatum,
  IIF(EinzHist.[Status] = 'S', NULL, Einsatz.EinsatzBez$LAN$) AS Außerdienststellungsgrund,
  WegGrund.WegGrundBez$LAN$ AS Tauschgrund,
  IIF(EinzHist.[Status] = 'S',  EinzHist.RestwertInfo, EinzHist.AusdRestw) AS Restwert,
  Kunden.VertragWaeID AS Restwert_WaeID,
  [Week].Woche AS [Ersteinsatz-Woche],
  EinzHist.IndienstDat AS Indienststellungsdatum,
  EinzHist.Kostenlos,
  Einzteil.RuecklaufG AS [Anzahl Wäschen gesamt],
  EinzHist.RuecklaufK AS [Anzahl Wäschen Kunde],
  Mitarbei.Name AS [Mitarbeiter Austausch-Scan]
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teilestatus on EinzHist.[Status] = Teilestatus.[Status]
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
JOIN [Week] ON DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN [Week].VonDat AND [Week].BisDat
LEFT JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
LEFT JOIN AustauschScan on AustauschScan.TeileID = EinzTeil.ID
LEFT JOIN Scans on AustauschScan.ScanID = Scans.ID
LEFT JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE EinzTeil.AltenheimModus = 0
  AND Kunden.ID = $3$
  AND (EinzHist.[Status] = N'S' OR EinzHist.AusdienstDat BETWEEN $STARTDATE$ AND $ENDDATE$);