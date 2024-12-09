DROP TABLE IF EXISTS #LsForExport;

CREATE TABLE #LsForExport (
  LsKoID int,
  EinzTeilID int
);

INSERT INTO #LsForExport (LsKoID, EinzTeilID)
SELECT LsKo.ID, Scans.EinzTeilID
FROM LsKo
JOIN LsPo ON LsPo.LsKoID = LsKo.ID
JOIN Scans ON Scans.LsPoID = LsPo.ID
JOIN Vsa ON Vsa.ID = LsKo.VsaID
JOIN Kunden ON Kunden.ID = Vsa.KundenID
WHERE Kunden.KdNr = 10006208
  AND Vsa.VsaNr = 5
  AND LsKo.Status >= N'O'
  AND LsKo.DruckZeitpunkt >= DATEADD(hour, -1, GETDATE());

IF @@ROWCOUNT > 0
BEGIN

  WITH ScanHistory AS (
    SELECT Scans.EinzTeilID, Scans.ID AS LastAusgangScanID, LAG(Scans.ID) OVER (PARTITION BY Scans.EinzTeilID ORDER BY Scans.ID) AS BeforeLastAusgangScanID
    FROM Scans
    WHERE Scans.ActionsID IN (102, 165)
      AND Scans.EinzTeilID IN (SELECT EinzTeilID FROM #LsForExport)
  )
  SELECT LsKo.LsNr,
    Vsa.VsaNr,
    VpsKoID = (
      SELECT TOP 1 VPSPo.VPSKoID
      FROM Scans
      JOIN VPSPo ON Scans.VPSPoID = VPSPo.ID
      WHERE Scans.EinzTeilID = EinzTeil.ID
        AND Scans.ActionsID = 126
        AND Scans.ID BETWEEN ISNULL(ScanHistory.BeforeLastAusgangScanID, 1) AND ScanHistory.LastAusgangScanID
      ORDER BY Scans.ID DESC
    ),
    EinzTeil.Code,
    LsKo.Datum,
    CAST(Kunden.KdNr AS nvarchar) + N'_' + CAST(Vsa.VsaNr AS nvarchar) AS _SPLIT_
  FROM EinzTeil
  JOIN Scans ON Scans.EinzTeilID = EinzTeil.ID
  JOIN ScanHistory ON Scans.ID = ScanHistory.LastAusgangScanID
  JOIN LsPo ON LsPo.ID = Scans.LsPoID
  JOIN LsKo ON LsKo.ID = LsPo.LsKoID
  JOIN Vsa ON Vsa.ID = LsKo.VsaID
  JOIN Kunden ON Kunden.ID = Vsa.KundenID
  WHERE LsKo.ID IN (SELECT LsKoID FROM #LsForExport)
  ORDER BY LsKo.LsNr;

END;