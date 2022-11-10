SELECT WegGrund.WegGrundBez$LAN$ AS Grund, EinzHist.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, EinzHist.ErstDatum, EinzHist.PatchDatum, EinzHist.Ausdienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS SGF, EinzHist.AusdRestw AS RestWert
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Status] ON EinzHist.[Status] = [Status].[Status] AND [Status].Tabelle = 'EINZHIST'
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN Week ON DATEADD(day, EinzHist.AnzTageImLager, EinzHist.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
  AND Kunden.ID IN ($ID$)
  AND EinzHist.[Status] = 'Y'
  AND WegGrund.ID IN ($3$)
  AND EinzHist.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Bereich.ID IN ($5$)
ORDER BY Kdnr, VsaNr, ArtikelNr;