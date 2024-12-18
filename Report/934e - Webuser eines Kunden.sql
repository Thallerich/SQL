/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-89377                                                                                                                  ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2024-12-18                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT WebUser.FullName AS [Name],
  Webuser.UserName AS [Benutzer],
  WebLogin.LastLoginTime AS [letzter Login],
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
LEFT JOIN (
  SELECT WebLogin.UserName, MAX(WebLogin.Zeitpunkt) AS LastLoginTime
  FROM WebLogin
  WHERE WebLogin.IsLogout = 0
    AND WebLogin.Success = 1
  GROUP BY WebLogin.UserName
) AS WebLogin ON WebUser.UserName = WebLogin.UserName
LEFT JOIN (
  SELECT DISTINCT Vsa.ID AS VsaID, WebUser.ID AS WebUserID
  FROM Vsa
  JOIN Webuser ON Vsa.KundenID = WebUser.KundenID
  WHERE Vsa.ID IN ( 
    SELECT Vsa.ID 
    FROM Vsa 
    JOIN WebUser AS wu ON wu.KundenID = Vsa.KundenID 
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = wu.ID 
    WHERE wu.ID = WebUser.ID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID) 
  )
  AND Vsa.AbteilID IN (  
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = WebUser.ID
  )
  AND Vsa.[Status] = N'A'
) AS VsaWebuser ON WebUser.ID = VsaWebuser.WebUserID
LEFT JOIN Vsa ON VsaWebuser.VsaID = Vsa.ID
WHERE WebUser.KundenID = $ID$
  AND WebUser.[Status] = N'A'
ORDER BY [Benutzer], VsaNr;