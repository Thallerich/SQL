SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzTeil.Code, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, EinzTeil.WegDatum AS Schrottdatum, ISNULL(Standort.SuchCode, N'<unbekannt>') AS [verschrottender Produktionsstandort], Kunden.KdNr AS [letzter Kunde], EinzTeil.Erstwoche AS [Ersteinsatz-Woche], EinzTeil.AnzWasch AS [Anzahl Wäschen], Artikel.MaxWaschen AS [maximale Wäschen], Artikel.EKPreis AS Einkaufspreis, (Artikel.EKPreis/IIF(Artikel.MaxWaschen = 0, 1, Artikel.MaxWaschen)) * (Artikel.MaxWaschen - EinzTeil.AnzWasch) * IIF(Artikel.MaxWaschen = 0, 0, 1) AS Restwert
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
LEFT JOIN Scans ON Scans.EinzTeilID = EinzTeil.ID AND Scans.GrundID = EinzTeil.WegGrundID
LEFT JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
LEFT JOIN Standort ON ArbPlatz.StandortID = Standort.ID
WHERE (Standort.ID IN ($2$) OR Standort.ID = -1 OR Standort.ID IS NULL)
  AND EinzTeil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EinzTeil.WegGrundID IN ($3$)
  AND Scans.ActionsID = 108 
ORDER BY Schrottdatum ASC;