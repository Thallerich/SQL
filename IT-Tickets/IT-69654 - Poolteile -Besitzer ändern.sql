DROP TABLE IF EXISTS #OwnerChange;
GO

DECLARE @VsaOwnerID int;
DECLARE @sqltext nvarchar(max);

SELECT @VsaOwnerID = Vsa.ID
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 10001925
  AND Vsa.VsaNr = 8;

CREATE TABLE #OwnerChange (
  EinzTeilID int PRIMARY KEY NOT NULL
);

SET @sqltext = N'INSERT INTO #OwnerChange (EinzTeilID)
SELECT EinzTeil.ID
FROM EinzTeil
WHERE (EinzTeil.Code IN (SELECT Barcode FROM _IT69654) OR EinzTeil.Code2 IN (SELECT Barcode FROM _IT69654))
  AND EinzTeil.VsaOwnerID != @vsaownerid;';

EXEC sp_executesql @sqltext, N'@vsaownerid int', @VsaOwnerID;

SET @sqltext = N'UPDATE EinzTeil SET VsaOwnerID = @vsaownerid
WHERE ID IN (SELECT EinzTeilID FROM #OwnerChange)';

EXEC sp_executesql @sqltext, N'@vsaownerid int', @VsaOwnerID;

GO

DROP TABLE IF EXISTS #OwnerChange;

GO