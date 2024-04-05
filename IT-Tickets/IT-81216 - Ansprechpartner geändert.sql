SELECT ChgLog.Timestamp,
  ChgLog.TableID,
  Mitarbei.Name AS [Änderungs-User],
  ChgLog.FieldName,
  CAST(LEFT(ChgLog.OldMemo, 100) AS varchar(100)) AS [Alter Wert],
  CAST(LEFT(ChgLog.NewMemo, 100) AS varchar(100)) AS [Neuer Wert],
  Arbeitsplatz = (
    SELECT TOP 1 ArbPlatz.ComputerName
    FROM LoginLog
    JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
    WHERE LoginLog.UserID = ChgLog.MitarbeiID
      AND LoginLog.LoginZeit < ChgLog.Timestamp
    ORDER BY LoginLog.LoginZeit DESC
  ),
  [Windows-Benutzer] = (
    SELECT TOP 1 LoginLog.WindowsUsername
    FROM LoginLog
    WHERE LoginLog.UserID = ChgLog.MitarbeiID
      AND LoginLog.LoginZeit < ChgLog.Timestamp
    ORDER BY LoginLog.LoginZeit DESC
  ),
  [Startzeit AdvanTex-Session] = (
    SELECT TOP 1 LoginLog.LoginZeit
    FROM LoginLog
    WHERE LoginLog.UserID = ChgLog.MitarbeiID
      AND LoginLog.LoginZeit < ChgLog.Timestamp
    ORDER BY LoginLog.LoginZeit DESC
  )
FROM ChgLog
JOIN Mitarbei ON ChgLog.MitarbeiID = Mitarbei.ID
WHERE ChgLog.TableName = N'SACHBEAR'
  AND ChgLog.TableID IN (557482, 555528, 557287, 569645, 630548, 645672, 806325, 806327, 808806, 808819, 862058, 862786, 865748)
ORDER BY [Timestamp] ASC;