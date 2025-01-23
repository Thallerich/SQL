SELECT Standort.Bez AS Produktion, Einzteil.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, ArtMisch.ArtMischBez$LAN$ AS Gewebe, ArtMisch.Gewicht AS [Flächengewicht g/m²], Artikel.StueckGewicht AS [Gewicht kg/Stück], Artikel.EKPreis, (SELECT [Week].Woche FROM [Week] WHERE DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN [Week].VonDat AND [Week].BisDat) AS [Erstauslieferungswoche], Einzteil.WegDatum AS [Schrott-Datum], WegGrund.WegGrundBez$LAN$ AS Schrottgrund, Einzteil.AnzSteril AS [Anzahl Steriliationen], Einzteil.RuecklaufG AS [Anzahl Wäschen], Einzteil.AnzImpregnier AS [Anzahl Imprägnierungen], KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr AS [KdNr letzter Kunde], Kunden.SuchCode AS [letzter Kunde]
FROM (
  SELECT EinzTeil.ID, EinzTeil.Code, EinzTeil.WegGrundID, EinzTeil.ArtikelID, EinzTeil.WegDatum, EinzTeil.AnzSteril, EinzTeil.RuecklaufG, EinzTeil.AnzImpregnier, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum, VsaID = (
		SELECT TOP 1 Scans.VsaID
		FROM Scans
		WHERE Scans.EinzTeilID = EinzTeil.ID
			AND Scans.LsPoID > 0
		ORDER BY Scans.ID DESC
	)
	FROM EinzTeil
	WHERE EinzTeil.WegGrundID > 0
		AND EinzTeil.[Status] = N'Z'
		AND EinzTeil.LastActionsID IN (SELECT Actions.ID FROM Actions WHERE UPPER(Actions.ActionsBez) LIKE N'%SCHROTT%')
		AND EinzTeil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
) AS EinzTeil
JOIN Vsa ON Einzteil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Artikel ON Einzteil.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtMisch ON Artikel.ArtMischID = ArtMisch.ID
JOIN WegGrund ON Einzteil.WegGrundID = WegGrund.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Artikel.BereichID = StandBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE Kunden.KdGfID IN ($3$)
  AND Kunden.FirmaID IN ($4$)
  AND Einzteil.WegGrundID IN ($2$)
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
  AND StandBer.ProduktionID IN ($5$)
  AND (($6$ <= 0) OR ($6$ > 0 AND Kunden.KdNr = $6$))
ORDER BY Artikelbezeichnung, [Schrott-Datum]