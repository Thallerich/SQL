DECLARE @doUpdate bit = 0;
DECLARE @User nchar(6) = N'POESHA';
DECLARE @MinutesAgo int = 15;

DECLARE @Entnahmeliste TABLE (
  EntnKoID int PRIMARY KEY
);

INSERT INTO @Entnahmeliste (EntnKoID)
SELECT EntnKo.ID
FROM EntnKo
WHERE EntnKo.[Status] = N'D'
  AND EntnKo.UserID_ = (SELECT ID FROM Mitarbei WHERE Username = @User)
  AND EntnKo.DruckDatum >= DATEADD(minute, @MinutesAgo * -1, GETDATE());

IF @doUpdate = 0
BEGIN
  SELECT EntnKo.ID AS Entnahmeliste, EntnKo.Status, EntnKo.DruckDatum, Standort.SuchCode AS Lager, Mitarbei.UserName AS LastUser
  FROM EntnKo
  JOIN Standort ON EntnKo.LagerID = Standort.ID
  JOIN Mitarbei ON EntnKo.UserID_ = Mitarbei.ID
  WHERE EntnKo.ID IN (SELECT EntnKoID FROM @Entnahmeliste);
END;

IF @doUpdate = 1
BEGIN
  UPDATE EntnKo SET [Status] = N'C', DruckDatum = NULL
  WHERE ID IN (SELECT EntnKoID FROM @Entnahmeliste);

  PRINT CAST(@@ROWCOUNT AS nvarchar) + N' Entnahmeliste auf ''abgeschlossen'' zurückgesetzt!';
END;