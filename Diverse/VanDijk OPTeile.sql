USE Wozabal
GO

CREATE TABLE #Teil (
  Code nvarchar(33) COLLATE Latin1_General_CS_AS
);

BULK INSERT #Teil FROM N'D:\AdvanTex\Temp\vandijk.txt'
WITH (FIELDTERMINATOR = N'\r', ROWTERMINATOR = N'\n');

-- 7548 rows
SELECT vd.Code AS Barcode, OPTeile.Code AS [Barcode AdvanTex], Artikel.ArtikelNr, Artikel.ArtikelBez, Status.StatusBez AS [aktueller Status], OPTeile.Erstwoche, FORMAT(OPTeile.Anlage_, 'd', 'de-AT') AS Anlagezeitpunkt
INTO #TmpVanDijk
FROM #Teil AS vd
LEFT OUTER JOIN OPTeile ON LEFT(OPTeile.Code, 9) = RTRIM(vd.Code)
LEFT OUTER JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
LEFT OUTER JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
WHERE NOT EXISTS (
  SELECT o.*
  FROM OPTeile AS o
  WHERE OPTeile.Code = o.Code2
    AND OPTeile.Erstwoche < o.Erstwoche
);

UPDATE tvd SET tvd.[Barcode AdvanTex] = u.[Barcode AdvanTex], tvd.ArtikelNr = u.ArtikelNr, tvd.ArtikelBez = u.ArtikelBez, tvd.[aktueller Status] = u.[aktueller Status], tvd.Erstwoche = u.Erstwoche, tvd.Anlagezeitpunkt = u.Anlagezeitpunkt
FROM #TmpVanDijk AS tvd
JOIN (
  SELECT vd.Code AS Barcode, OPTeile.Code2 AS [Barcode AdvanTex], Artikel.ArtikelNr, Artikel.ArtikelBez, Status.StatusBez AS [aktueller Status], OPTeile.Erstwoche, FORMAT(OPTeile.Anlage_, 'd', 'de-AT') AS Anlagezeitpunkt
  FROM #Teil AS vd
  LEFT OUTER JOIN OPTeile ON LEFT(OPTeile.Code2, 9) = RTRIM(vd.Code) COLLATE Latin1_General_CI_AS
  LEFT OUTER JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  LEFT OUTER JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
  WHERE vd.Code IN (SELECT Barcode FROM #TmpVanDijk WHERE [Barcode AdvanTex] IS NULL)
) AS u ON u.Barcode = tvd.Barcode;

SELECT * FROM #TmpVanDijk ORDER BY Barcode ASC;

DROP TABLE #TmpVanDijk;
DROP TABLE #Teil;

GO