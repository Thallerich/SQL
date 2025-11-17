DECLARE @AppVersionUpdate TABLE (
  MdeDevID int,
  AppVersionID int
);

WITH AppCurrentVersion AS (
  SELECT AppVersion.ID AS AppVersionID, CurrentVersionPerApp.Art, CurrentVersionPerApp.CurrentVersion
  FROM (
    SELECT AppVersion.AppID, Apps.Art, MAX(AppVersion.[Version]) AS CurrentVersion
    FROM dbSystem.dbo.AppVersion
    JOIN dbSystem.dbo.Apps ON AppVersion.AppID = Apps.ID
    GROUP BY AppVersion.AppID, Apps.Art
  ) CurrentVersionPerApp
  JOIN dbSystem.dbo.AppVersion ON CurrentVersionPerApp.AppID = AppVersion.AppID AND CurrentVersionPerApp.CurrentVersion = AppVersion.[Version]
)
INSERT INTO @AppVersionUpdate (MdeDevID, AppVersionID)
SELECT MdeDev.ID, AppCurrentVersion.AppVersionID
FROM MdeDev
JOIN dbSystem.dbo.AppVersion ON MdeDev.TargetAppVersionID = AppVersion.ID
JOIN dbSystem.dbo.Apps ON AppVersion.AppID = Apps.ID
JOIN AppCurrentVersion ON MdeDev.Art = AppCurrentVersion.Art
WHERE MdeDev.TargetAppVersionID > 0
  AND MdeDev.TargetAppVersionID != AppCurrentVersion.AppVersionID;

UPDATE MdeDev SET TargetAppVersionID = [@AppVersionUpdate].AppVersionID
FROM @AppVersionUpdate
WHERE MdeDev.ID = [@AppVersionUpdate].MdeDevID;