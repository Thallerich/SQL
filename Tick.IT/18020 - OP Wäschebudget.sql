BEGIN TRY
  DROP TABLE #TmpBudget;
END TRY
BEGIN CATCH
END CATCH;

SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Status.Artikelstatus, 0 AS Bestand2010, 0 AS Schrott2010, 0 AS Nichtdreher180, 0 AS Nichtdreher2014, 0 AS TeileAlt, 0 AS Drehung180
INTO #TmpBudget
FROM Artikel, (
  SELECT Status.Status, Status.StatusBez$LAN$ AS Artikelstatus
  FROM Status
  WHERE Status.Tabelle = 'ARTIKEL'
) AS Status
WHERE Artikel.BereichID = 106 --Produktbereich OP-Textilien
  AND Artikel.ArtGruID <> 70 --keine Instrumente
  AND Artikel._IstMWID <> 3 --keine Einweg-Artikel
  AND Artikel.Status = Status.Status
  AND NOT EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.ArtikelID = Artikel.ID
  )
;

UPDATE Budget SET Budget.Bestand2010 = x.Anz
FROM #TmpBudget AS Budget, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpBudget)
    AND (OPTeile.WegDatum IS NULL OR OPTeile.WegDatum >= '01.01.2010')
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE Budget.ArtikelID = x.ArtikelID;

UPDATE Budget SET Budget.Schrott2010 = x.Anz
FROM #TmpBudget AS Budget, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpBudget)
    AND OPTeile.Status = 'Z'
    AND OPTeile.WegDatum >= '01.01.2010'
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE Budget.ArtikelID = x.ArtikelID;

UPDATE Budget SET Budget.Nichtdreher180 = x.Anz
FROM #TmpBudget AS Budget, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpBudget)
    AND OPTeile.Status < 'W'
    AND (OPTeile.LastScanTime IS NULL OR DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) > 180)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE Budget.ArtikelID = x.ArtikelID;

UPDATE Budget SET Budget.Nichtdreher2014 = x.Anz
FROM #TmpBudget AS Budget, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpBudget)
    AND OPTeile.Status < 'W'
    AND (OPTeile.LastScanTime IS NULL OR OPTeile.LastScanTime < '01.01.2014 00:00:00')
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE Budget.ArtikelID = x.ArtikelID;

UPDATE Budget SET Budget.TeileAlt = x.Anz
FROM #TmpBudget AS Budget, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpBudget)
    AND OPTeile.ErstWoche < '2010/01'
    AND OPTeile.ErstWoche <> '1980/01'
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE Budget.ArtikelID = x.ArtikelID;

UPDATE Budget SET Budget.Drehung180 = x.Anz
FROM #TmpBudget AS Budget, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpBudget)
    AND OPTeile.LastScanTime IS NOT NULL
    AND DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) <= 180
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE Budget.ArtikelID = x.ArtikelID;

SELECT * FROM #TmpBudget;