CREATE TABLE #FixMe (
  EinzTeilID int PRIMARY KEY CLUSTERED,
  AltenheimModus tinyint
);

GO

INSERT INTO #FixMe (EinzTeilID, AltenheimModus)
SELECT EinzHist.EinzTeilID, IIF(Traeger.Kurzzeitpflege = 1, 2, 1) AS AltenheimModus
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID AND EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
WHERE Traeger.Altenheim = 1
  AND EinzTeil.AltenheimModus = 0;

GO

UPDATE EinzTeil SET AltenheimModus = #FixMe.AltenheimModus
FROM #FixMe
WHERE #FixMe.EinzTeilID = EinzTeil.ID;

GO

DROP TABLE #FixMe;

GO