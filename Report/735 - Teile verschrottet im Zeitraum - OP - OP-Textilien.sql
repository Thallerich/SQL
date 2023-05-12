SELECT Standort.Bez AS Produktion, Einzteil.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, Artikel.EKPreis, Einzteil.ErstWoche AS [Erstauslieferungswoche], Einzteil.WegDatum AS [Schrott-Datum], WegGrund.WegGrundBez$LAN$ AS Schrottgrund, Einzteil.AnzSteril AS [Anzahl Steriliationen], Einzteil.RuecklaufG AS [Anzahl Wäschen], Einzteil.AnzImpregnier AS [Anzahl Imprägnierungen], Kunden.KdNr AS [KdNr letzter Kunde], Kunden.SuchCode AS [letzter Kunde]
FROM Einzteil
JOIN Vsa ON Einzteil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON Einzteil.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN WegGrund ON Einzteil.WegGrundID = WegGrund.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Artikel.BereichID = StandBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Kunden.KdGfID IN ($3$)
  AND Kunden.FirmaID IN ($4$)
  AND Einzteil.WegGrundID IN ($2$)
  AND Einzteil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
  AND StandBer.ProduktionID IN ($5$)
  AND (($6$ <= 0) OR ($6$ > 0 AND Kunden.KdNr = $6$))
ORDER BY Artikelbezeichnung, [Schrott-Datum]