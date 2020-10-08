WITH ActiveUsers AS (
  SELECT Kunden.KdGfID, COUNT(WebUser.UserName) AS Anzahl
  FROM WebUser
  JOIN Kunden ON WebUser.KundenID = Kunden.ID
  WHERE WebUser.ParentWebuserID < 0
    AND Webuser.Status = N'A'
    AND Kunden.Status = N'A'
    AND EXISTS (
      SELECT WebLogin.*
      FROM WebLogin
      WHERE WebLogin.UserName = WebUser.UserName
        AND CAST(WebLogin.Zeitpunkt AS date) >= CAST(DATEADD(day, -31, GETDATE()) AS date)
        AND WebLogin.Success = 1
        AND WebLogin.IsLogout = 0
    )
    AND WebUser.ID > 0
  GROUP BY Kunden.KdGfID
),
TotalUsers AS (
  SELECT Kunden.KdGfID, COUNT(WebUser.UserName) AS Anzahl
  FROM WebUser
  JOIN Kunden ON WebUser.KundenID = Kunden.ID
  WHERE WebUser.ParentWebuserID < 0
    AND WebUser.ID > 0
  GROUP BY Kunden.KdGfID
),
AverageUsersPerDay As (
  SELECT x.KdGfID, AVG(Anzahl) AS AnzahlSchnitt
  FROM (
    SELECT Kunden.KdGfID, CAST(WebLogin.Zeitpunkt AS date) AS Datum, COUNT(DISTINCT WebUser.ID) AS Anzahl
    FROM WebLogin
    JOIN WebUser ON WebLogin.UserName = WebUser.UserName
    JOIN Kunden ON WebUser.KundenID = Kunden.ID
    WHERE CAST(WebLogin.Zeitpunkt AS date) >= CAST(DATEADD(year, -1, GETDATE()) AS date)
      AND WebLogin.Success = 1
      AND WebLogin.IsLogout = 0
      AND WebUser.ParentWebuserID < 0
    GROUP BY Kunden.KdGfID, CAST(WebLogin.Zeitpunkt AS date)
  ) AS x
  GROUP BY x.KdGFID
),
LoginsPerKdGf AS (
  SELECT Kunden.KdGfID, COUNT(WebLogin.ID) AS Anzahl
  FROM WebLogin
  JOIN WebUser ON WebLogin.UserName = WebUser.UserName
  JOIN Kunden ON WebUser.KundenID = Kunden.ID
  WHERE CAST(WebLogin.Zeitpunkt AS date) >= CAST(DATEADD(year, -1, GETDATE()) AS date)
    AND WebLogin.Success = 1
    AND WebLogin.IsLogout = 0
    AND WebUser.ParentWebuserID < 0
  GROUP BY Kunden.KdGfID
),
TotalLogins AS (
  SELECT COUNT(WebLogin.ID) AS Anzahl
  FROM WebLogin
  JOIN WebUser ON WebLogin.UserName = WebUser.UserName
  WHERE CAST(WebLogin.Zeitpunkt AS date) >= CAST(DATEADD(year, -1, GETDATE()) AS date)
    AND WebLogin.Success = 1
    AND WebLogin.IsLogout = 0
    AND WebUser.ParentWebuserID < 0
)
SELECT Geschäftsbereich = KdGf.KurzBez,
  Zeitraum = FORMAT(DATEADD(year, -1, GETDATE()), N'dd.MM.yyyy', N'de-AT') + ' - ' + FORMAT(GETDATE(), N'dd.MM.yyyy', N'de-AT'),
  [User gesamt] = TotalUsers.Anzahl,
  [User aktiv] = ActiveUsers.Anzahl,
  [User aktiv %] = ROUND(CAST(ActiveUsers.Anzahl AS float(24)) / CAST(TotalUsers.Anzahl AS float(24)) * 100, 2),
  [User inaktiv] = TotalUsers.Anzahl - ActiveUsers.Anzahl,
  [User inaktiv %] = ROUND(CAST((TotalUsers.Anzahl - ActiveUsers.Anzahl) AS float(24)) / CAST(TotalUsers.Anzahl AS float(24)) * 100, 2),
  [Anzahl Logins] = LoginsPerKdGf.Anzahl,
  [Anzahl Logins %] = ROUND(CAST(LoginsPerKdGf.Anzahl AS float(24)) / CAST(TotalLogins.Anzahl AS float(24)) * 100, 2),
  [∅ Useranzahl pro Tag] = AverageUsersPerDay.AnzahlSchnitt
FROM KdGf
JOIN ActiveUsers ON KdGf.ID = ActiveUsers.KdGfID
JOIN TotalUsers ON KdGf.ID = TotalUsers.KdGfID
JOIN LoginsPerKdGf ON KdGf.ID = LoginsPerKdGf.KdGfID
JOIN AverageUsersPerDay ON KdGf.ID = AverageUsersPerDay.KdGFID
CROSS JOIN TotalLogins
WHERE KdGf.KurzBez IN (N'MED', N'GAST', N'JOB')
ORDER BY [User aktiv] DESC;