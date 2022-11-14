SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Einsatz.EinsatzBez$LAN$ AS Außerdienststellungsgrund, WegGrund.WeggrundBez$LAN$ AS [Schrott-Grund], RwArt.RwArtBez$LAN$ AS [Restwert-Art], TeilSoFa.EPreis AS Restwert, Produktion.SuchCode AS Produktion, Betreuer.Name AS Kundenbetreuer, Kundenservice.Name AS Kundenservice
FROM TeilSofa
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Einsatz ON TeilSoFa.AusdienstGrund = Einsatz.EinsatzGrund
JOIN RwArt ON TeilSoFa.RwArtID = RwArt.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON VsaBer.BetreuerID = Betreuer.ID
JOIN Mitarbei AS Kundenservice ON VsaBer.ServiceID = Kundenservice.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
WHERE TeilSoFa.SoFaArt = N'R'        /* Restwert-Abrechnung */
  AND TeilSoFa.[Status] = N'L'       /* Abrechnung geplant  */
  AND Vsa.StandKonID IN ($1$);