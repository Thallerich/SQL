SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, WegGrund.WeggrundBez$LAN$ AS Schrottgrund, COUNT(EinzTeil.ID) AS [Anzahl Ausgeschieden]
FROM EinzTeil
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE EinzTeil.WegGrundID > 0
	AND EinzTeil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
	AND Vsa.StandKonID IN ($2$)
	AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, WegGrund.WegGrundBez$LAN$;