WITH Gerätestatus AS (
  SELECT Status.Status, Status.StatusBez
  FROM Status
  WHERE Status.Tabelle = N'MDEDEV'
)
SELECT Gerätestatus.StatusBez AS Gerätestatus, MdeDev.Bez AS Gerätebezeichnung, MdeDev.SerienNr, MdeDev.IMEI, MdeDev.Type, MdeDev.LetzterZugriff, Mitarbei.Name AS LetzterBenutzer, FahrtenZugewiesen = (
    SELECT COUNT(Fahrt.ID)
    FROM Fahrt
    WHERE Fahrt.MDEDevID = MdeDev.ID
  ),
  GPSDaten = (
    SELECT COUNT(GPSLog.ID)
    FROM GPSLog
    WHERE GPSLog.MDEDevID = MdeDev.ID
  )
FROM _MdeDeviceList AS CLImport
JOIN MdeDev ON CLImport.IMEI = MdeDev.IMEI
JOIN Mitarbei ON MdeDev.LastMitarbeiID = Mitarbei.ID
JOIN Gerätestatus ON MdeDev.Status = Gerätestatus.Status
WHERE MdeDev.Art = N'H'

UNION

SELECT Gerätestatus.StatusBez AS Gerätestatus, MdeDev.Bez AS Gerätebezeichnung, MdeDev.SerienNr, MdeDev.IMEI, MdeDev.Type, MdeDev.LetzterZugriff, Mitarbei.Name AS LetzterBenutzer, FahrtenZugewiesen = (
    SELECT COUNT(Fahrt.ID)
    FROM Fahrt
    WHERE Fahrt.MDEDevID = MdeDev.ID
  ),
  GPSDaten = (
    SELECT COUNT(GPSLog.ID)
    FROM GPSLog
    WHERE GPSLog.MDEDevID = MdeDev.ID
  )
FROM MdeDev
JOIN Mitarbei ON MdeDev.LastMitarbeiID = Mitarbei.ID
JOIN Gerätestatus ON MdeDev.Status = Gerätestatus.Status
WHERE MdeDev.IMEI IS NULL
  AND MdeDev.Art = N'H'
ORDER BY LetzterZugriff ASC;


-- active devices not in list
WITH Gerätestatus AS (
  SELECT Status.Status, Status.StatusBez
  FROM Status
  WHERE Status.Tabelle = N'MDEDEV'
)
SELECT Gerätestatus.StatusBez AS Gerätestatus, MdeDev.Bez AS Gerätebezeichnung, MdeDev.SerienNr, MdeDev.IMEI, MdeDev.Type, MdeDev.LetzterZugriff, Mitarbei.Name AS LetzterBenutzer, FahrtenZugewiesen = (
    SELECT COUNT(Fahrt.ID)
    FROM Fahrt
    WHERE Fahrt.MDEDevID = MdeDev.ID
  ),
  GPSDaten = (
    SELECT COUNT(GPSLog.ID)
    FROM GPSLog
    WHERE GPSLog.MDEDevID = MdeDev.ID
  )
FROM MdeDev
JOIN Mitarbei ON MdeDev.LastMitarbeiID = Mitarbei.ID
JOIN Gerätestatus ON MdeDev.Status = Gerätestatus.Status
WHERE MdeDev.IMEI IS NOT NULL
  AND MdeDev.IMEI NOT IN (SELECT IMEI FroM _MdeDeviceList)
  AND MdeDev.Art = N'H'
  AND MdeDev.Status = N'A'
ORDER BY LetzterZugriff ASC;
