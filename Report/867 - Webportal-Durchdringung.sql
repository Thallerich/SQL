/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-93341                                                                                                                  ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2025-04-15                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* gather last login date for all linked web-users                                                                                 */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #LastLoginCollection, #LastWebLogin;

SELECT
  WebUserID_0 = WebUser.ID,
  KundenID_0 = WebUser.KundenID,
  LastLogin_0 = (SELECT MAX(WebLogin.Zeitpunkt) FROM WebLogin WHERE WebLogin.IsLogout = 0 AND WebLogin.Success = 1 AND WebLogin.UserName = WebUser.UserName),
  WebUserID_1 = WebUser1.ID,
  KundenID_1 = WebUser1.KundenID,
  LastLogin_1 = (SELECT MAX(WebLogin.Zeitpunkt) FROM WebLogin WHERE WebLogin.IsLogout = 0 AND WebLogin.Success = 1 AND WebLogin.UserName = WebUser1.UserName AND WebUser1.ID > 0),
  WebUserID_2 = WebUser2.ID,
  KundenID_2= WebUser2.KundenID,
  LastLogin_2 = (SELECT MAX(WebLogin.Zeitpunkt) FROM WebLogin WHERE WebLogin.IsLogout = 0 AND WebLogin.Success = 1 AND WebLogin.UserName = WebUser2.UserName AND WebUser2.ID > 0),
  WebUserID_3 = WebUser3.ID,
  KundenID_3 = WebUser3.KundenID,
  LastLogin_3 = (SELECT MAX(WebLogin.Zeitpunkt) FROM WebLogin WHERE WebLogin.IsLogout = 0 AND WebLogin.Success = 1 AND WebLogin.UserName = WebUser3.UserName AND WebUser3.ID > 0),
  WebUserID_4 = WebUser4.ID,
  KundenID_4 = WebUser4.KundenID,
  LastLogin_4 = (SELECT MAX(WebLogin.Zeitpunkt) FROM WebLogin WHERE WebLogin.IsLogout = 0 AND WebLogin.Success = 1 AND WebLogin.UserName = WebUser4.UserName AND WebUser4.ID > 0)
INTO #LastLoginCollection
FROM WebUser
JOIN WebUser AS WebUser1 ON WebUser.ParentWebuserID = WebUser1.ID
JOIN WebUser AS WebUser2 ON WebUser1.ParentWebuserID = WebUser2.ID
JOIN WebUser AS WebUser3 ON WebUser2.ParentWebuserID = WebUser3.ID
JOIN WebUser AS WebUser4 ON WebUser3.ParentWebuserID = WebUser4.ID
WHERE WebUser.IstVorlage = 0;

SELECT
  WebUserID = WebUserID_0,
  KundenID = KundenID_0,
  LastLogin = 
    CASE
      WHEN LastLogin_0 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_0
      WHEN LastLogin_1 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_1
      WHEN LastLogin_2 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_2
      WHEN LastLogin_3 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_3
      WHEN LastLogin_4 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_3, '1980-01-01') THEN LastLogin_4
      ELSE CAST(NULL AS datetime2)
    END
INTO #LastWebLogin
FROM #LastLoginCollection;

INSERT INTO #LastWebLogin
SELECT
  WebUserID = WebUserID_1,
  KundenID = KundenID_1,
  LastLogin = 
    CASE
      WHEN LastLogin_0 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_0
      WHEN LastLogin_1 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_1
      WHEN LastLogin_2 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_2
      WHEN LastLogin_3 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_3
      WHEN LastLogin_4 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_3, '1980-01-01') THEN LastLogin_4
      ELSE CAST(NULL AS datetime2)
    END
FROM #LastLoginCollection
WHERE WebUserID_1 > 0;

INSERT INTO #LastWebLogin
SELECT
  WebUserID = WebUserID_2,
  KundenID = KundenID_2,
  LastLogin = 
    CASE
      WHEN LastLogin_0 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_0
      WHEN LastLogin_1 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_1
      WHEN LastLogin_2 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_2
      WHEN LastLogin_3 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_3
      WHEN LastLogin_4 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_3, '1980-01-01') THEN LastLogin_4
      ELSE CAST(NULL AS datetime2)
    END
FROM #LastLoginCollection
WHERE WebUserID_2 > 0;

INSERT INTO #LastWebLogin
SELECT
  WebUserID = WebUserID_3,
  KundenID = KundenID_3,
  LastLogin = 
    CASE
      WHEN LastLogin_0 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_0
      WHEN LastLogin_1 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_1
      WHEN LastLogin_2 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_2
      WHEN LastLogin_3 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_3
      WHEN LastLogin_4 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_3, '1980-01-01') THEN LastLogin_4
      ELSE CAST(NULL AS datetime2)
    END
FROM #LastLoginCollection
WHERE WebUserID_3 > 0;

INSERT INTO #LastWebLogin
SELECT
  WebUserID = WebUserID_4,
  KundenID = KundenID_4,
  LastLogin = 
    CASE
      WHEN LastLogin_0 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_0 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_0
      WHEN LastLogin_1 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_1 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_1
      WHEN LastLogin_2 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_3, '1980-01-01') AND LastLogin_2 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_2
      WHEN LastLogin_3 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_3 >= ISNULL(LastLogin_4, '1980-01-01') THEN LastLogin_3
      WHEN LastLogin_4 >= ISNULL(LastLogin_0, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_1, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_2, '1980-01-01') AND LastLogin_4 >= ISNULL(LastLogin_3, '1980-01-01') THEN LastLogin_4
      ELSE CAST(NULL AS datetime2)
    END
FROM #LastLoginCollection
WHERE WebUserID_4 > 0;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-93341                                                                                                                  ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2025-04-15                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT KdGf.KurzBez AS Geschäftsbereich, ABC.ABCBez$LAN$ AS [ABC-Klasse], Holding.Holding, Standort.SuchCode AS Haupstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Vsa.NutztSelfServiceApp AS [verwendet Self-Service App?], Mitarbei.Name AS [Kundenbetreuer], CAST(IIF(WebVsa.VsaID IS NULL, 0, 1) AS bit) AS [Hat Webportal?], CAST(IIF(UHFVSA.VsaID IS NULL, 0, 1) AS bit) AS [UHF-Prozess?], LastWebLogin.LastLoginTime AS [letzter Webportal-Login]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT JOIN (
  SELECT Vsa.ID AS VsaID
  FROM Vsa
  WHERE Vsa.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      JOIN Webuser ON WebUAbt.WebuserID = Webuser.ID
      WHERE Webuser.[Status] = N'A'
    )
    AND Vsa.ID IN (  
      SELECT Vsa.ID
      FROM Vsa
      JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
      LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
      WHERE Webuser.[Status] = N'A'
        AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
    )
) AS WebVSA ON WebVSA.VsaID = Vsa.ID
LEFT JOIN (
  SELECT VsaBer.VsaID
  FROM VsaBer
  JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
  WHERE (VsaBer.AnfAusEpo > 1 OR (VsaBer.AnfAusEpo = -1 AND KdBer.AnfAusEpo > 1))
) AS UHFVSA ON UHFVSA.VsaID = Vsa.ID
LEFT JOIN (SELECT y.VsaID, y.BetreuerID
  FROM (
    SELECT x.VsaID, x.BetreuerID, DENSE_RANK() OVER (PARTITION BY x.VsaID ORDER BY x.RowCounter DESC) SortRank
    FROM (
      SELECT VsaBer.VsaID, VsaBer.BetreuerID, COUNT(VsaBer.ID) AS RowCounter
      FROM VsaBer
      WHERE VsaBer.Status = N'A'
      GROUP BY VsaBer.VsaID, VsaBer.BetreuerID
    ) AS x
  ) AS y
  WHERE y.SortRank = 1) AS VsaBetreuer ON VsaBetreuer.VsaID = Vsa.ID
LEFT JOIN Mitarbei ON VsaBetreuer.BetreuerID = Mitarbei.ID
LEFT JOIN (
  SELECT Vsa.ID AS VsaID, MAX(#LastWebLogin.LastLogin) AS LastLoginTime
  FROM Vsa
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN #LastWebLogin ON #LastWebLogin.KundenID = Kunden.ID
  WHERE EXISTS (
      SELECT WebUAbt.*
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = #LastWebLogin.WebUserID
        AND WebUAbt.AbteilID = Vsa.AbteilID
    )
    AND (
      EXISTS (
        SELECT WebUVsa.*
        FROM WebUVsa
        WHERE WebUVsa.WebUserID = #LastWebLogin.WebUserID
          AND WebUVsa.VsaID = Vsa.ID
      )
      OR NOT EXISTS (
        SELECT WebUVsa.*
        FROM WebUVsa
        WHERE WebUVsa.WebUserID = #LastWebLogin.WebUserID
      )
    )
  GROUP BY Vsa.ID
) AS LastWebLogin ON LastWebLogin.VsaID = Vsa.ID
WHERE Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND Kunden.StandortID IN ($3$)
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Vsa.[Status] = N'A'
ORDER BY KdNr, [VSA-Nr];