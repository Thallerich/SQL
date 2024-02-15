WITH UserStats AS (
  SELECT COALESCE(Standort.Bez + N' (' + Standort.SuchCode + N')', MStandort.Bez + N' (' + MStandort.SuchCode + N')') AS Standort, LoginLog.UserID AS MitarbeiID, COUNT(LoginLog.ID) AS AnzLogins
  FROM LoginLog
  JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Standort ON ArbPlatz.StandortID = Standort.ID
  JOIN Firma ON Standort.FirmaID = Firma.ID
  JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
  JOIN Firma MFirma ON Mitarbei.FirmaID = MFirma.ID
  JOIN Standort MStandort ON Mitarbei.StandortID = MStandort.ID
  WHERE LoginLog.LogInZeit >= N'2024-01-01'
    AND Mitarbei.[Status] = N'A'
    AND Mitarbei.UserName NOT LIKE N'JOB%'
  GROUP BY COALESCE(Standort.Bez + N' (' + Standort.SuchCode + N')', MStandort.Bez + N' (' + MStandort.SuchCode + N')'), LoginLog.UserID

  UNION ALL

  SELECT COALESCE(Standort.Bez + N' (' + Standort.SuchCode + N')', MStandort.Bez + N' (' + MStandort.SuchCode + N')') AS Standort, LoginLog.UserID AS MitarbeiID, COUNT(LoginLog.ID) AS AnzLogins
  FROM LoginLog
  JOIN ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Standort ON ArbPlatz.StandortID = Standort.ID
  JOIN Firma ON Standort.FirmaID = Firma.ID
  JOIN Mitarbei ON LoginLog.UserID = Mitarbei.ID
  JOIN Firma MFirma ON Mitarbei.FirmaID = MFirma.ID
  JOIN Standort MStandort ON Mitarbei.StandortID = MStandort.ID
  WHERE LoginLog.LogInZeit >= N'2024-01-01'
    AND Mitarbei.[Status] = N'A'
    AND Mitarbei.UserName NOT LIKE N'JOB%'
  GROUP BY COALESCE(Standort.Bez + N' (' + Standort.SuchCode + N')', MStandort.Bez + N' (' + MStandort.SuchCode + N')'), LoginLog.UserID
)
SELECT UserStats.Standort, COUNT(DISTINCT UserStats.MitarbeiID) AS [Anzahl User]
FROM UserStats
JOIN (
  SELECT MitarbeiID, MAX(AnzLogins) AS MaxLoginCount
  FROM UserStats
  GROUP BY MitarbeiID
) us1 ON UserStats.MitarbeiID = us1.MitarbeiID AND UserStats.AnzLogins = us1.MaxLoginCount
GROUP BY UserStats.Standort;


SELECT N'LOTO' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez != N'Zagreb'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'BELG' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Belgrad'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez != N'Belgrad'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'TRZI' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Trzin'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez != N'Trzin'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'ROGA' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Rogaška'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez != N'Rogaška'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'LOTO + BELG' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Belgrad'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez IN (N'Trzin', N'Rogaška')
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'LOTO + TRZI' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Trzin'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez IN (N'Belgrad', N'Rogaška')
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'LOTO + ROGA' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Rogaška'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez IN (N'Trzin', N'Belgrad')
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'BELG + TRZI' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Belgrad'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Trzin'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez IN (N'Zagreb', N'Rogaška')
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'BELG + ROGA' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Belgrad'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Rogaška'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez IN (N'Zagreb', N'Trzin')
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'TRZI + ROGA' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Trzin'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Rogaška'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND NOT EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez IN (N'Zagreb', N'Belgrad')
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'LOTO + BELG + TRZI' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Belgrad'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Trzin'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'LOTO + BELG + ROGA' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Belgrad'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Rogaška'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )

UNION ALL

SELECT N'LOTO + BELG + TRZI + ROGA' AS Standort, Mitarbei.Name
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Sichtbar ON SichtUsr.SichtbarID = Sichtbar.iD
WHERE Sichtbar.Bez = N'Zagreb'
  AND SichtUsr.Sehen = 1
  AND Firma.SuchCode != N'FA14'
  AND Mitarbei.Status = N'A'
  AND Mitarbei.UserName != N'ADVSUP'
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Belgrad'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Trzin'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  )
  AND EXISTS (
    SELECT su.*
    FROM SichtUsr su
    JOIN Sichtbar ON su.SichtbarID = Sichtbar.ID
    WHERE Sichtbar.Bez = N'Rogaška'
      AND su.Sehen = 1
      AND su.UserID = SichtUsr.UserID
  );