USE Kundentransfer;
GO

DROP TABLE IF EXISTS #TmpBarcodeDoppelt;
GO

/* -- Temporäre Tabelle mit den in beiden Systemen vorhandenen Barcodes erstellen -- */
SELECT DISTINCT SAL_TEILE_ALL.BarcodeOhneNull AS Barcode
INTO #TmpBarcodeDoppelt
FROM SAL_TEILE_ALL
WHERE EXISTS (
    SELECT Wozabal_Teile.*
	FROM Wozabal_Teile
	WHERE Wozabal_Teile.BarcodeOhneNull = SAL_TEILE_ALL.BarcodeOhneNull
  )
  OR EXISTS (
    SELECT Wozabal_Teile.*
	FROM Wozabal_Teile
	WHERE Wozabal_Teile.RentomatChip = SAL_TEILE_ALL.BarcodeOhneNull
  )
  OR EXISTS (
    SELECT Wozabal_Lagerteile.*
	FROM Wozabal_Lagerteile
	WHERE Wozabal_Lagerteile.BarcodeOhneNull = SAL_TEILE_ALL.BarcodeOhneNull
  );

/* -- Barcode-Überschneidungen gesamt -- */
SELECT COUNT(*) AS [Anzahl Teile]
FROM #TmpBarcodeDoppelt;

/* -- Status der betroffenen Teile - Salesianer -- */
SELECT SAL_TEILE_ALL.[Status], COUNT(DISTINCT TBD.Barcode) AS [Anzahl Teile]
FROM #TmpBarcodeDoppelt AS TBD
JOIN SAL_TEILE_ALL ON SAL_TEILE_ALL.BarcodeOhneNull = TBD.Barcode
GROUP BY SAL_TEILE_ALL.[Status];

/* -- Status der betroffenen Teile - Wozabal -- */
SELECT Woz.[Status], COUNT(DISTINCT TBD.Barcode) AS [Anzahl Teile]
FROM #TmpBarcodeDoppelt AS TBD
JOIN (
	SELECT Wozabal_Teile.[Status], Wozabal_Teile.BarcodeOhneNull
	FROM Wozabal_Teile
	WHERE Wozabal_Teile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)

	UNION ALL

	SELECT Wozabal_Lagerteile.[aktueller Status] AS [Status], Wozabal_Lagerteile.BarcodeOhneNull
	FROM Wozabal_Lagerteile
	WHERE Wozabal_Lagerteile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)
) AS Woz ON Woz.BarcodeOhneNull = TBD.Barcode
GROUP BY Woz.[Status];

/* -- TOP 10 Kunden - Salesianer -- */
SELECT TOP 10 SAL_TEILE_ALL.KdNr, SAL_TEILE_ALL.[Name] AS Kundenname, COUNT(DISTINCT TBD.Barcode) AS [betroffene Teile]
FROM #TmpBarcodeDoppelt AS TBD
JOIN SAL_TEILE_ALL ON SAL_TEILE_ALL.BarcodeOhneNull = TBD.Barcode
WHERE SAL_TEILE_ALL.KdNr IS NOT NULL
GROUP BY SAL_TEILE_ALL.KdNr, SAL_TEILE_ALL.[Name]
ORDER BY [betroffene Teile] DESC;

/* -- TOP 10 Kunden - Wozabal -- */
SELECT TOP 10 Wozabal_Teile.KdNr, Wozabal_Teile.Kunde AS Kundenname, COUNT(DISTINCT TBD.Barcode) AS [betroffene Teile]
FROM #TmpBarcodeDoppelt AS TBD
JOIN Wozabal_Teile ON Wozabal_Teile.BarcodeOhneNull = TBD.Barcode
WHERE Wozabal_Teile.KdNr IS NOT NULL
GROUP BY Wozabal_Teile.KdNr, Wozabal_Teile.Kunde
ORDER BY [betroffene Teile] DESC;

/* -- Teile je prod. Betrieb - Wozabal -- */
SELECT Woz.ProdBetrieb AS [Produzierender Betrieb], COUNT(DISTINCT TBD.Barcode) AS [betroffene Teile]
FROM #TmpBarcodeDoppelt AS TBD
JOIN (
	SELECT Wozabal_Teile.internProdBetrieb AS ProdBetrieb, Wozabal_Teile.BarcodeOhneNull
	FROM Wozabal_Teile
	WHERE Wozabal_Teile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)

	UNION ALL

	SELECT Wozabal_Lagerteile.Lagerstandort AS ProdBetrieb, Wozabal_Lagerteile.BarcodeOhneNull
	FROM Wozabal_Lagerteile
	WHERE Wozabal_Lagerteile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)
) AS Woz ON Woz.BarcodeOhneNull = TBD.Barcode
GROUP BY Woz.ProdBetrieb
ORDER BY [betroffene Teile] DESC;

/* -- Teile je prod. Betrieb - Salesianer -- */
SELECT SAL_TEILE_ALL.INT_PROD_BETRIEB AS [Produzierender Betrieb], COUNT(DISTINCT TBD.Barcode) AS [betroffene Teile]
FROM #TmpBarcodeDoppelt AS TBD
JOIN SAL_TEILE_ALL ON SAL_TEILE_ALL.BarcodeOhneNull = TBD.Barcode
GROUP BY SAL_TEILE_ALL.INT_PROD_BETRIEB
ORDER BY [betroffene Teile] DESC;

/* -- Teile je prod. Betrieb - ältestes Teil wird umgepatcht -- */
SELECT IIF(AlterTeile.W_AlterInWochen > AlterTeile.S_AlterInWochen, ISNULL(AlterTeile.W_ProdBetrieb, N'Woz_unbekannt'), ISNULL(AlterTeile.S_ProdBetrieb, N'Sal_unbekannt')) AS [Produzierender Betrieb], 
  COUNT(DISTINCT AlterTeile.Barcode) AS [betroffene Teile]
FROM (
  SELECT AlterWoz.BarcodeOhneNull AS Barcode, AlterWoz.ProdBetrieb AS W_ProdBetrieb, AlterSal.ProdBetrieb AS S_ProdBetrieb, AlterWoz.AlterInWochen AS W_AlterInWochen, AlterSal.AlterInWochen AS S_AlterInWochen
  FROM (
	SELECT Wozabal_Teile.internProdBetrieb AS ProdBetrieb, Wozabal_Teile.BarcodeOhneNull, Wozabal_Teile.AlterInWochen
	FROM Wozabal_Teile
	WHERE Wozabal_Teile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)

	UNION ALL

	SELECT Wozabal_Lagerteile.Lagerstandort AS ProdBetrieb, Wozabal_Lagerteile.BarcodeOhneNull, DATEDIFF(week, Wozabal_Lagerteile.[Erstes Einsatzdatum], CAST(N'2018-04-19' AS date)) AS AlterInWochen
	FROM Wozabal_Lagerteile
	WHERE Wozabal_Lagerteile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)
	  AND Wozabal_Lagerteile.BarcodeOhneNull NOT IN (
	    SELECT Wozabal_Teile.BarcodeOhneNull
	    FROM Wozabal_Teile
	    WHERE Wozabal_Teile.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)
	  )
  ) AS AlterWoz
   JOIN (
	SELECT SAL_TEILE_ALL.INT_PROD_BETRIEB AS ProdBetrieb, SAL_TEILE_ALL.BarcodeOhneNull, DATEDIFF(week, SAL_TEILE_ALL.ERSTES_EINSATZDATUM, CAST(N'2018-04-19' AS date)) AS AlterInWochen
	FROM SAL_TEILE_ALL
	WHERE SAL_TEILE_ALL.BarcodeOhneNull IN (SELECT Barcode FROM #TmpBarcodeDoppelt)
  ) AS AlterSal ON AlterSal.BarcodeOhneNull = AlterWoz.BarcodeOhneNull
) AS AlterTeile
GROUP BY IIF(AlterTeile.W_AlterInWochen > AlterTeile.S_AlterInWochen, ISNULL(AlterTeile.W_ProdBetrieb, N'Woz_unbekannt'), ISNULL(AlterTeile.S_ProdBetrieb, N'Sal_unbekannt'))
ORDER BY [betroffene Teile] DESC;