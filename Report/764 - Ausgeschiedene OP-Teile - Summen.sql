/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #SchrottTeile, #LastVsaScan;

SELECT EinzTeil.ID, EinzTeil.WegGrundID, EinzTeil.ArtikelID, EinzTeil.WegDatum, CAST(NULL AS int) AS VsaID
INTO #SchrottTeile
FROM EinzTeil
WHERE EinzTeil.WegGrundID > 0
	AND EinzTeil.[Status] = N'Z'
	AND EinzTeil.LastActionsID IN (SELECT Actions.ID FROM Actions WHERE UPPER(Actions.ActionsBez) LIKE N'%SCHROTT%')
	AND EinzTeil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$;

SELECT Scans.EinzTeilID, MAX(Scans.ID) AS LastVsaScanID
INTO #LastVsaScan
FROM Scans
WHERE Scans.LsPoID > 0
	AND Scans.EinzTeilID IN (SELECT ID FROM #SchrottTeile)
GROUP BY Scans.EinzTeilID

UPDATE #SchrottTeile SET VsaID = LastVsa.VsaID
FROM (
	SELECT Scans.EinzTeilID, Scans.VsaID
	FROM #LastVsaScan AS LastVsaScan
	JOIN Scans ON LastVsaScan.LastVsaScanID = Scans.ID
) AS LastVsa
WHERE LastVsa.EinzTeilID = #SchrottTeile.ID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: OPTeile                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, WegGrund.WeggrundBez$LAN$ AS Schrottgrund, COUNT(EinzTeil.ID) AS [Anzahl Ausgeschieden]
FROM #SchrottTeile AS EinzTeil
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE Vsa.StandKonID IN ($2$)
	AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, WegGrund.WegGrundBez$LAN$;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Datumsbereic                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT $STARTDATE$ AS VonDatum, $ENDDATE$ AS EndDatum;