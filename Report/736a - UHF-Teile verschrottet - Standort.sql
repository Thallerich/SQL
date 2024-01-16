SELECT Standort.Bez AS Produktionsstandort, Artikel.ArtikelNr, Artikel.ArtikelNr2 AS [BMD-ArtikelNr], Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, COUNT(EINZTEIL.ID) AS Menge, (SUM(EINZTEIL.RuecklaufG) / COUNT(EINZTEIL.ID)) AS [Durchschnitt Waschzyklen]
FROM EINZTEIL, ZielNr, Standort, Artikel, WegGrund
WHERE EINZTEIL.ZielNrID = ZielNr.ID
  AND ZielNr.ProduktionsID = Standort.ID
  AND Standort.ID IN ($3$)
  AND ZielNr.GeraeteNr IS NOT NULL
  AND EINZTEIL.ArtikelID = Artikel.ID
  AND Artikel.EAN IS NOT NULL --nur UHF-Artikel
  AND EINZTEIL.WegGrundID = WegGrund.ID
  AND EINZTEIL.WegGrundID IN ($2$)
  AND EINZTEIL.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EINZTEIL.Status = 'Z'
GROUP BY Standort.Bez, Artikel.ArtikelNr, ARtikel.ArtikelNr2, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$
ORDER BY Produktionsstandort, Artikelbezeichnung;