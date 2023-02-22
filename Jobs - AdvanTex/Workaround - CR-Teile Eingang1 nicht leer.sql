DECLARE @bereichid int = (SELECT ID FROM Bereich WHERE Bereich = N'CR');
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
DECLARE @TeilFix TABLE (
  EinzHistID int NOT NULL PRIMARY KEY CLUSTERED
);

INSERT INTO @TeilFix (EinzHistID)
SELECT EinzHist.ID
FROM EinzHist
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
WHERE KdBer.BereichID = @bereichid
  AND EinzHist.Status < N''Q''
  AND EinzHist.Status != N''5''
  AND EinzHist.Eingang1 IS NOT NULL
  AND EinzHist.IsCurrEinzHist = 1
  AND NOT EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.ActionsID = 1
  );

UPDATE EinzHist SET Eingang1 = NULL
WHERE ID IN (SELECT EinzHistID FROM @TeilFix);
';

EXEC sp_executesql @sqltext, N'@bereichid int', @bereichid;