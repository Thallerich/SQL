SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, WegGrund.WeggrundBez$LAN$ AS Schrottgrund, COUNT(EinzTeil.ID) AS [Anzahl Ausgeschieden]
FROM (
	SELECT EinzTeil.ID, EinzTeil.WegGrundID, EinzTeil.ArtikelID, EinzTeil.WegDatum, VsaID = (
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
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE Vsa.StandKonID IN ($2$)
	AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, WegGrund.WegGrundBez$LAN$;