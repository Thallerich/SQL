WITH WebVSA AS (
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
),
LastWebLogin AS (
  SELECT Vsa.ID AS VsaID, MAX(WebLogin.Zeitpunkt) AS LastLoginTime
  FROM Vsa
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN WebUser ON WebUser.KundenID = Kunden.ID
  JOIN WebLogin ON WebLogin.UserName = WebUser.UserName
  WHERE WebLogin.Success = 1
    AND WebLogin.IsLogout = 0
    AND EXISTS (
      SELECT WebUAbt.*
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = WebUser.ID
        AND WebUAbt.AbteilID = Vsa.AbteilID
    )
    AND (
      EXISTS (
        SELECT WebUVsa.*
        FROM WebUVsa
        WHERE WebUVsa.WebUserID = WebUser.ID
          AND WebUVsa.VsaID = Vsa.ID
      )
      OR NOT EXISTS (
        SELECT WebUVsa.*
        FROM WebUVsa
        WHERE WebUVsa.WebUserID = WebUser.ID
      )
    )
  GROUP BY Vsa.ID
),
UHFVSA AS (
  SELECT VsaBer.VsaID
  FROM VsaBer
  JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
  WHERE (VsaBer.AnfAusEpo > 1 OR (VsaBer.AnfAusEpo = -1 AND KdBer.AnfAusEpo > 1))
),
VsaBetreuer AS (
  SELECT y.VsaID, y.BetreuerID
  FROM (
    SELECT x.VsaID, x.BetreuerID, DENSE_RANK() OVER (PARTITION BY x.VsaID ORDER BY x.RowCounter DESC) SortRank
    FROM (
      SELECT VsaBer.VsaID, VsaBer.BetreuerID, COUNT(VsaBer.ID) AS RowCounter
      FROM VsaBer
      WHERE VsaBer.Status = N'A'
      GROUP BY VsaBer.VsaID, VsaBer.BetreuerID
    ) AS x
  ) AS y
  WHERE y.SortRank = 1
)
SELECT KdGf.KurzBez AS Geschäftsbereich, ABC.ABCBez$LAN$ AS [ABC-Klasse], Holding.Holding, Standort.SuchCode AS Haupstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Vsa.NutztSelfServiceApp AS [verwendet Self-Service App?], Mitarbei.Name AS [Kundenbetreuer], CAST(IIF(WebVsa.VsaID IS NULL, 0, 1) AS bit) AS [Hat Webportal?], CAST(IIF(UHFVSA.VsaID IS NULL, 0, 1) AS bit) AS [UHF-Prozess?], LastWebLogin.LastLoginTime AS [letzter Webportal-Login]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT JOIN WebVSA ON WebVSA.VsaID = Vsa.ID
LEFT JOIN UHFVSA ON UHFVSA.VsaID = Vsa.ID
LEFT JOIN VsaBetreuer ON VsaBetreuer.VsaID = Vsa.ID
LEFT JOIN Mitarbei ON VsaBetreuer.BetreuerID = Mitarbei.ID
LEFT JOIN LastWebLogin ON LastWebLogin.VsaID = Vsa.ID
WHERE Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND Kunden.StandortID IN ($3$)
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Vsa.[Status] = N'A'
ORDER BY KdNr, [VSA-Nr];