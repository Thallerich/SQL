WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'EINZHIST')
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
)
SELECT ServiceMA.Name AS [Kundenservice-Mitarbeiter], BetreuerMA.Name AS [Betreuer], Kunden.Kdnr, Kunden.Suchcode as Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS Trägerstatus, EinzHist.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Anlage_ AS [Teil angelegt am], EntnKo.ID AS EntnahmelistenNr, EntnKo.Anlage_ AS [Entnahmeliste angelegt am], EntnKo.DruckDatum AS [Druckdatum Entnahmeliste], [Entnahme-Datum] = (
  SELECT MAX(Scans.[DateTime])
  FROM Scans
  WHERE Scans.EinzHistID = EinzHist.ID
    AND Scans.ActionsID = 57
), EntnKo.PatchDatum AS [Patchdatum Entnahmeliste], Einsatz.Einsatzbez$LAN$
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS ServiceMA ON KdBer.ServiceID = ServiceMA.ID
JOIN Mitarbei AS BetreuerMA ON KdBer.BetreuerID = BetreuerMA.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Einsatz ON EinzHist.EinsatzGrund = Einsatz.EinsatzGrund
LEFT JOIN EntnPo ON EinzHist.EntnPoID = EntnPo.ID AND EinzHist.EntnPoID > 0
LEFT JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
WHERE EinzHist.Anlage_ > N'2019-04-01 00:00:00'
  AND Artikel.BereichID = 100
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND Traeger.Status != N'I'
  AND Teilestatus.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$)
  AND Kunden.StandortID IN ($3$)
  AND ServiceMA.ID IN ($4$)
  AND BetreuerMA.ID IN ($5$)
  AND CAST(EinzHist.Anlage_ AS date) BETWEEN $STARTDATE$ AND $ENDDATE$
ORDER BY [Entnahmeliste angelegt am];