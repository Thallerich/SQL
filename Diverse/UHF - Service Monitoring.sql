WITH LastScanPerDestination AS (
  SELECT TOP 1 Scans.ZielNrID, Scans.[DateTime] AS LastScanTime, Scans.Anlage_ AS LastCreationTime
  FROM Scans
  WHERE Scans.ZielNrID IN (
    SELECT ZielNr.ID
    FROM ZielNr
    WHERE ZielNr.Funktion IN (N'B', N'E')
      AND EXISTS (
        SELECT ArbPSetT.*
        FROM ArbPSetT
        WHERE ArbPSetT.ZielNrID = ZielNr.ID
          AND ArbPSetT.Bereich = N'UHFReader'
          AND ArbPSetT.Schluessel = N'IP'
          AND ArbPSetT.Wert IS NOT NULL
          AND ArbPSetT.ZielNrID > 0
      )
  )
  ORDER BY Scans.ID DESC
)
SELECT ZielNr.ID AS ZielNrID, ZielNr.ZielNrBez, DATEDIFF(minute, LastScanPerDestination.LastScanTime, GETDATE()) AS [Minuten seit letztem Scan], LastScanPerDestination.LastScanTime AS [letzter Scan-Zeitpunkt]
FROM LastScanPerDestination
JOIN ZielNr ON LastScanPerDestination.ZielNrID = ZielNr.ID

GO

SELECT TOP 1 LogItem.Bez, LogItem.Memo, LogItem.Anlage_
FROM LogItem
WHERE LogItem.LogCaseID = (SELECT ID FROM LogCase WHERE Bez = N'UHFService')
ORDER BY LogItem.ID DESC

GO