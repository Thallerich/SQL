DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'JOBAPP');
DECLARE @datefrom datetime2 = N'2023-04-01 00:00:00';
DECLARE @dateto datetime2 = N'2023-05-01 00:00:00';
DECLARE @sqltext nvarchar(max);

IF OBJECT_ID('tempdb..#ResultSet') IS NULL
BEGIN
  CREATE TABLE #ResultSet (
    Source nchar(3) COLLATE Latin1_General_CS_AS,
    KundenID int,
    Anzahl int
  );
END
ELSE
BEGIN
  DELETE FROM #ResultSet;
END;

SET @sqltext = N'
  INSERT INTO #ResultSet (Source, KundenID, Anzahl)
  SELECT N''App'' AS Source, Vsa.KundenID, COUNT(Hinweis.ID) AS Anzahl
  FROM Hinweis
  JOIN EinzHist ON Hinweis.EinzHistID = EinzHist.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  WHERE Hinweis.EingabeMitarbeiID = @userid
    AND Hinweis.EingabeDatum BETWEEN @from AND @to
    AND Hinweis.JpgTop > 0
    AND Hinweis.JpgLeft > 0
  GROUP BY Vsa.KundenID;
';

EXEC sp_executesql @sqltext, N'@userid int, @from datetime2, @to datetime2', @UserID, @datefrom, @dateto;

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, #ResultSet.Anzahl AS [Anzahl erfasst über App]
FROM #ResultSet
JOIN Kunden ON #ResultSet.KundenID = Kunden.ID;

GO