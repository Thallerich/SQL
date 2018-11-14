WITH LsPoAnz AS (
  SELECT LsPo.LsKoID, COUNT(LsPo.ID) AS PosAnz
  FROM LsPo
  GROUP BY LsPo.LsKoID
  HAVING COUNT(LsPo.ID) = 1
)
SELECT LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Status, LsKo.Datum, LsPo.RechPoID
INTO #TmpLsDelete
FROM LsKo
JOIN LsPo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LsPoAnz ON LsPoAnz.LsKoID = LsKo.ID
WHERE Artikel.ArtikelNr = N'ZUS';

DELETE FROM LsPo
WHERE LsPo.LsKoID IN (SELECT LsKoID FROM #TmpLsDelete);

DELETE FROM LsKo
WHERE LsKo.ID IN (SELECT LsKoID FROM #TmpLsDelete);

DROP TABLE #TmpLsDelete;