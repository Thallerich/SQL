SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OPTeile.Code, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, OPTeile.WegDatum AS Schrottdatum, ISNULL(Standort.SuchCode, N'<unbekannt>') AS [verschrottender Produktionsstandort], Kunden.KdNr AS [letzter Kunde], OPTeile.Erstwoche AS [Ersteinsatz-Woche], OPTeile.AnzWasch AS [Anzahl Wäschen], Artikel.MaxWaschen AS [maximale Wäschen], Artikel.EKPreis AS Einkaufspreis, (Artikel.EKPreis/IIF(Artikel.MaxWaschen = 0, 1, Artikel.MaxWaschen)) * (Artikel.MaxWaschen - OPTeile.AnzWasch) * IIF(Artikel.MaxWaschen = 0, 0, 1) AS Restwert
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN WegGrund ON OPTeile.WegGrundID = WegGrund.ID
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
LEFT JOIN OPScans ON OPScans.OPTeileID = OPTeile.ID AND OPScans.ActionsID = 108 AND OPScans.OPGrundID = OPTeile.WegGrundID
LEFT JOIN ArbPlatz ON OPScans.ArbPlatzID = ArbPlatz.ID
LEFT JOIN Standort ON ArbPlatz.StandortID = Standort.ID
WHERE (Standort.ID IN ($2$) OR Standort.ID = -1 OR Standort.ID IS NULL)
  AND OPTeile.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND OPTeile.WegGrundID IN ($3$)
ORDER BY Schrottdatum ASC;