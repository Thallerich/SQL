SELECT KdGf.KurzBez AS Geschäftsbereich, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung],
Traeger.Traeger, Traeger.Vorname, Traeger.Nachname,
 EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Einsatz.EinsatzBez$LAN$ AS Außerdienststellungsgrund, WegGrund.WeggrundBez$LAN$ AS [Schrott-Grund], RwArt.RwArtBez$LAN$ AS [Restwert-Art], TeilSoFa.EPreis AS Restwert, TeilSoFaStatus.StatusBez AS [Status], IIF($3$ = 1, RechKo.RechNr, NULL) AS Rechnungsnummer, IIF($3$ = 1, Rechko.RechDat, NULL) AS Rechnungsdatum, Produktion.SuchCode AS Produktion, Betreuer.Name AS Kundenbetreuer, Kundenservice.Name AS Kundenservice, EinzHist.Ausdienst
FROM TeilSofa
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILSOFA'
) AS TeilSoFaStatus ON TeilSoFa.[Status] = TeilSoFaStatus.[Status]
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN Einsatz ON TeilSoFa.AusdienstGrund = Einsatz.EinsatzGrund
JOIN RwArt ON TeilSoFa.RwArtID = RwArt.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Holding ON Holding.ID = Kunden.HoldingID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON VsaBer.BetreuerID = Betreuer.ID
JOIN Mitarbei AS Kundenservice ON VsaBer.ServiceID = Kundenservice.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Traeger ON Traeger.Id = EinzHist.TraegerID
WHERE TeilSoFa.SoFaArt = N'R' /* Restwert-Abrechnung */
  AND (
    (TeilSoFa.[Status] = N'L' AND $3$ = 0) /* Abrechnung geplant  */
    OR
    (TeilSoFa.[Status] = N'P' AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$ AND $3$ = 1) /* abgerechnet, nicht wieder gutgeschrieben */
  )
  AND Vsa.StandKonID IN ($1$);