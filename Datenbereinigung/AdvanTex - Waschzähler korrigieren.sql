/*
Anbei das Skript zur Korrektur der Waschzähler.
Das Skript sollte unter einer Stunde durchgelaufen sein. Die Schleife zum korrigieren der Scans auf Menge 0 dauerte im Testmandanten 23 Minuten.
Es bleiben 1134 aktive oder kürzlich ausgemusterte Teile mit Waschzähler > 250 übrig. Stichproben haben ergeben, dass diese tatsächlich so häufig gewaschen (oder gelesen) wurden.
*/

-- Fall Barcode als Waschzähler
SELECT ID EinzteilID, Code, Code2, RueckLaufG
INTO #tmpBarcode
FROM EinzTeil
WHERE Einzteil.RuecklaufG > 1000000

SELECT SUM(IIF(Scans.ID IS NOT NULL, 1, 0)) Einlesungen, #tmpBarcode.EinzteilID 
INTO #tmpBarcode2
FROM #tmpBarcode
LEFT OUTER JOIN Scans ON #tmpBarcode.EinzTeilID = Scans.EinzTeilID AND Scans.Menge = 1
GROUP BY #tmpBarcode.EinzTeilID

UPDATE EinzTeil SET RueckLaufG = #tmpBarcode2.Einlesungen 
FROM #tmpBarcode2
WHERE #tmpBarcode2.EinzteilID = EinzTeil.ID  --82 Datensätze


-- Fall hunderte Nachwäsche-Scans durch SDC
SELECT EinzTeilID, COUNT(*) AnzNachwaesche 
INTO #tmpNachwaesche
FROM Scans
WHERE ActionsID = 54
GROUP BY EinzTeilID
HAVING COUNT(*) >100

SELECT SUM(IIF(Scans.ID IS NOT NULL, 1, 0)) Einlesungen, #tmpNachwaesche.EinzteilID 
INTO #tmpNachwaesche2
FROM #tmpNachwaesche
LEFT OUTER JOIN Scans ON #tmpNachwaesche.EinzTeilID = Scans.EinzTeilID AND Scans.Menge = 1
GROUP BY #tmpNachwaesche.EinzTeilID

UPDATE EinzTeil SET RueckLaufG = #tmpNachwaesche2.Einlesungen 
FROM #tmpNachwaesche2
WHERE #tmpNachwaesche2.EinzteilID = EinzTeil.ID
AND #tmpNachwaesche2.Einlesungen > 0  --18 Datensätze

-- Fall mehrere hundert Einlesungen hintereinander
SELECT EinzTeilID, COUNT(*) AnzEinlesungen 
INTO #tmpX
FROM Scans
WHERE ActionsID IN (1,100)
GROUP BY EinzTeilID
HAVING COUNT(*) > 350   --13.134 

--SELECT Scans.ID, Scans.ActionsID, Scans.EinzTeilID, Scans.DateTime 
--FROM Scans, #tmp3
--WHERE #tmp3.EinzTeilID = Scans.EinzTeilID
--AND Scans.ActionsID IN (1, 100)

BEGIN TRY DROP TABLE #tmp4; END TRY BEGIN CATCH END CATCH;

WITH Ranked AS (
    SELECT
        Scans.ID, Scans.ActionsID, Scans.EinzTeilID, Scans.DateTime,
        DATEPART(yy, Scans.DateTime) AS ISOYear,
        DATEPART(isowk, Scans.DateTime) AS ISOWeek,
        ROW_NUMBER() OVER (
            PARTITION BY Scans.EinzTeilID, DATEPART(yy, Scans.DateTime), DATEPART(isowk, Scans.DateTime)
            ORDER BY Scans.DateTime
        ) AS rn
    FROM Scans, #tmpX x
    WHERE x.EinzTeilID = Scans.EinzTeilID
    AND Scans.ActionsID IN (1, 100)    
)
SELECT *
INTO #tmp4
FROM Ranked
WHERE rn = 1;  --1.822.490

CREATE INDEX "tmpID" ON #tmp4 ("ID")  WITH (FILLFACTOR = 100);
CREATE INDEX "tmpEinzteilID" ON #tmp4 ("EinzTeilID")  WITH (FILLFACTOR = 100);

SELECT TOP 0 ID
INTO #tmpTblForDelete 
FROM #tmp4;

DECLARE @EinzTeilID BIGINT;
DECLARE @rows INT = 1;
DECLARE @cnt INT;
WHILE (@rows > 0) BEGIN 
  SET @cnt = (SELECT COUNT(*) FROM #tmp4);
  --PRINT 'cnt to Delete: ' + CAST(@cnt AS NVARCHAR);
  SET @EinzTeilID = (SELECT TOP 1 EinzTeilID FROM #tmp4);
  
  INSERT INTO #tmpTblForDelete (ID)
  SELECT Scans.ID
  FROM Scans 
  WHERE Scans.EinzTeilID = @EinzTeilID 
  AND Scans.ActionsID IN (1, 100)   
  AND NOT EXISTS(SELECT x.ID FROM #tmp4 x WHERE Scans.ID = x.ID AND x.EinzTeilID = @EinzTeilID) 
  
  UPDATE Scans SET Menge = 0, Info = 'manuell korrigiert für Waschzähler-Anpassung'
  FROM Scans
  INNER JOIN #tmpTblForDelete x ON Scans.ID = x.ID;  

  DELETE FROM #tmp4 WHERE EinzTeilID = @EinzTeilID;
  DELETE FROM #tmpTblForDelete;
  SET @rows = @@rowcount; 
END;   --1433,64 Sekunden = 23 Minuten

DROP TABLE #tmpTblForDelete;
BEGIN TRY DROP TABLE #tmp5 END TRY BEGIN CATCH END CATCH

SELECT SUM(IIF(Scans.ID IS NOT NULL, 1, 0)) Einlesungen, #tmpX.EinzteilID 
INTO #tmp5
FROM #tmpX
LEFT OUTER JOIN Scans ON #tmpX.EinzTeilID = Scans.EinzTeilID AND Scans.Menge = 1
GROUP BY #tmpX.EinzTeilID

UPDATE EinzTeil SET RueckLaufG = #tmp5.Einlesungen 
FROM #tmp5
WHERE #tmp5.EinzteilID = EinzTeil.ID  --13.134 Teile

-- Fall nie gelesene erfasste Teile
SELECT EinzTeil.ID
INTO #tmpErfasste
FROM Einzteil, EinzHist
WHERE Einzteil.RueckLaufG > 1 
AND Einzteil.Status = 'A'
AND EinzHist.Status = 'A'
AND Einzteil.CurrEinzHistID = EinzHist.ID  
--AND NOT EXISTS(SELECT ID FROM SCans WHERE Scans.EinzteilID = EinzTeil.ID AND Scans.Menge = 1) 
AND NOT EXISTS(SELECT ID FROM SCans WHERE Scans.EinzteilID = EinzTeil.ID) --447.843
--AND EXISTS(SELECT ID FROM SCans WHERE Scans.EinzteilID = EinzTeil.ID) --296

UPDATE EinzTeil SET RueckLaufG = 0
FROM #tmpErfasste
WHERE #tmpErfasste.ID = EinzTeil.ID  --447.839


-- Fall jetzt noch aktive oder kürzlich ausgemusterte Teile, die auch in AdvanTex getauft wurden (keine Migrationsteile)
SELECT Einzteil.ID, EinzTeil.Code, EinzTeil.Status, EinzTeil.ArtGroeID, EinzTeil.RueckLaufG
INTO #tmpGetauft
FROM EinzTeil
WHERE RueckLaufG > 250
AND (WegDatum IS NULL OR WegDatum > '2024-01-01') 
ORDER BY 1 DESC

SELECT *
INTO #tmpGetauft2
FROM #tmpGetauft
WHERE EXISTS(SELECT Scans.ID FROM Scans WHERE Scans.ActionsID = 127 AND Scans.EinzTeilID = #tmpGetauft.ID)

SELECT SUM(IIF(Scans.ID IS NOT NULL, 1, 0)) Einlesungen, #tmpGetauft2.ID 
INTO #tmpGetauft3
FROM #tmpGetauft2
LEFT OUTER JOIN Scans ON #tmpGetauft2.ID = Scans.EinzTeilID AND Scans.Menge = 1
GROUP BY #tmpGetauft2.ID

UPDATE EinzTeil SET RueckLaufG = #tmpGetauft3.Einlesungen 
FROM #tmpGetauft3
WHERE #tmpGetauft3.ID = EinzTeil.ID   --82.807 

-- Fall Waschzähler falsch aus ABS übernommen?
SELECT Einzteil.ID, EinzTeil.Code, EinzTeil.Status, EinzTeil.ArtGroeID, EinzTeil.RueckLaufG
INTO #tmpABS
FROM EinzTeil
WHERE RueckLaufG > 250
AND (WegDatum IS NULL OR WegDatum > '2024-01-01') 

SELECT SUM(IIF(Scans.ID IS NOT NULL, 1, 0)) Einlesungen, #tmpABS.ID 
INTO #tmpABS2
FROM #tmpABS
LEFT OUTER JOIN Scans ON #tmpABS.ID = Scans.EinzTeilID AND Scans.Menge = 1
GROUP BY #tmpABS.ID

UPDATE EinzTeil SET RueckLaufG = #tmpABS2.Einlesungen 
FROM #tmpABS2
WHERE #tmpABS2.ID = EinzTeil.ID   --54.991