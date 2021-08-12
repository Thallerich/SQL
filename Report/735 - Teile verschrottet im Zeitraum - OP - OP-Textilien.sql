SELECT OPTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, OPTeile.ErstWoche AS [Erstauslieferungswoche], OPTeile.WegDatum AS [Schrott-Datum], WegGrund.WegGrundBez$LAN$ AS Schrottgrund, OPTeile.AnzSteril AS [Anzahl Steriliationen], OPTeile.AnzWasch AS [Anzahl Wäschen], OPTeile.AnzImpregnier AS [Anzahl Imprägnierungen]
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN WegGrund ON OPTeile.WegGrundID = WegGrund.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Artikel.BereichID = StandBer.BereichID
WHERE Kunden.KdGfID IN ($3$)
  AND Kunden.FirmaID IN ($4$)
  AND OPTeile.WegGrundID IN ($2$)
  AND OPTeile.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
  AND StandBer.ProduktionID IN ($5$)
ORDER BY Artikelbezeichnung, [Schrott-Datum];