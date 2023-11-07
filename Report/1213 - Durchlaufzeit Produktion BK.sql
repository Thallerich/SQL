/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ LoadData                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #EinAusScan;

CREATE TABLE #EinAusScan (
  EinzHistID int,
  Eingang date,
  Ausgang date,
  WochenInProd AS DATEDIFF(week, Eingang, Ausgang)
);

DECLARE @from datetime2 = CAST($STARTDATE$ AS datetime2);
DECLARE @to datetime2 = DATEADD(day, 1, CAST($ENDDATE$ AS datetime2));
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
INSERT INTO #EinAusScan (EinzHistID, Eingang, Ausgang)
SELECT x.EinzHistID, x.EinAusDat AS Eingang, x.EinAusNext AS Ausgang
FROM (
  SELECT Scans.EinzHistID, Scans.ActionsID, Scans.EinAusDat, LEAD(Scans.EinAusDat) OVER (PARTITION BY Scans.EinzHistID ORDER BY Scans.DateTime ASC) AS EinAusNext
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN @from AND @to
    AND Scans.ActionsID IN (1, 2)
    AND Scans.EinAusDat IS NOT NULL
) x
WHERE x.ActionsID = 1;
';

EXEC sp_executesql @sqltext, N'@from datetime2, @to datetime2', @from, @to;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reportdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, #EinAusScan.Eingang AS [Abholung], #EinAusScan.Ausgang AS [Anlieferung], #EinAusScan.WochenInProd AS [Wochen bei Salesianer]
FROM #EinAusScan
JOIN EinzHist ON #EinAusScan.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
WHERE Kunden.ID IN ($3$)
  AND #EinAusScan.WochenInProd IS NOT NULL;