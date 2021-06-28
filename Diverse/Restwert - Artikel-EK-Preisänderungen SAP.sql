WITH LastEKChange AS (
  SELECT ChgLog.TableID, MAX(ChgLog.ID) AS ChgLogID
  FROM ChgLog
  WHERE ChgLog.TableName = N'ARTIKEL' AND ChgLog.FieldName = N'EkPreis'
  GROUP BY ChgLog.TableID
),
SAPEKChangeCount AS (
  SELECT ChgLog.TableID, COUNT(ChgLog.ID) AS ChangeCount
  FROM ChgLog
  WHERE ChgLog.TableName = N'ARTIKEL' AND ChgLog.FieldName = N'EkPreis'
    AND ChgLog.MitarbeiID = (SELECT ID FROM Mitarbei WHERE UserName = N'SAP')
  GROUP BY ChgLog.TableID
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EkPreis, Artikel.EkPreisSeit, ChgLog.OldValue AS [EkPreis alt], ChgLog.[Timestamp] AS Änderungszeitpunkt, Mitarbei.UserName AS Änderungsuser, SAPEKChangeCount.ChangeCount AS [Anzahl EKPreis-Änderungen durch SAP]
FROM Artikel
LEFT JOIN LastEKChange ON LastEKChange.TableID = Artikel.ID
LEFT JOIN ChgLog ON LastEKChange.ChgLogID = ChgLog.ID
LEFT JOIN Mitarbei ON ChgLog.MitarbeiID = Mitarbei.ID
LEFT JOIN SAPEKChangeCount ON SAPEKChangeCount.TableID = Artikel.ID
WHERE Artikel.ID > 0
  AND Artikel.LiefID = (SELECT ID FROM Lief WHERE LiefNr = 100)
  AND Artikel.ArtiTypeID = 1
ORDER BY Artikel.ArtikelNr;