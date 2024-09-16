DROP TABLE IF EXISTS #Partfix;
GO

SELECT EinzHist.ID
INTO #Partfix
FROM EinzHist
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.KdArtiID = 34910249
  AND EinzHist.[Status] = N'S'
  AND EinzHist.NachfolgeEinzHistID < 0;

GO

UPDATE EinzHist SET [Status] = N'Q', AusdienstGrund = N'?', WegGrundID = -1, StopAuftragID = -1, UserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
WHERE ID IN (SELECT ID FROM #Partfix);

GO