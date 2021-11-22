SELECT WebUser.Username, WebUser.FullName, ParentWebUser.Username AS [übergeordneter Web-User], Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstellenbezeichnung
FROM WebUser
LEFT JOIN WebUser AS ParentWebUser ON WebUser.ParentWebuserID = ParentWebUser.ID AND ParentWebUser.ID > 0
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN WebUAbt ON WebUAbt.WebUserID = WebUser.ID
JOIN Abteil ON WebUAbt.AbteilID = Abteil.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND WebUser.Status = N'A'
ORDER BY UserName ASC;

GO

SELECT WebUser.Username, WebUser.FullName, ParentWebUser.Username AS [übergeordneter Web-User], Kunden.KdNr, Kunden.SuchCode AS Kunde, Kostenstellen = STUFF(
  (
    SELECT DISTINCT N' || ' + Abteil.Bez
    FROM WebUAbt
    JOIN Abteil ON WebUAbt.AbteilID = Abteil.ID
    WHERE WebUAbt.WebUserID = WebUser.ID
    FOR XML PATH (N'')
  ), 1, 4, N''
)
FROM WebUser
LEFT JOIN WebUser AS ParentWebUser ON WebUser.ParentWebuserID = ParentWebUser.ID AND ParentWebUser.ID > 0
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND WebUser.Status = N'A'
ORDER BY UserName ASC;

GO