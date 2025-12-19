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
WHERE ((Kunden.KdNr = 7700428 AND Vsa.VsaNr = 5) OR (Kunden.KdNr = 7701091 AND Vsa.VsaNr IN (2, 5)))
  AND LsKo.Status >= N'O'
  AND LsKo.DruckZeitpunkt >= DATEADD(hour, -1, GETDATE());

IF @@ROWCOUNT > 0
BEGIN

  SELECT DISTINCT
    LsKo.LsNr,
    Vsa.VsaNr,
    VPSPo.VpsKoID,
    EinzTeil.Code,
    LsKo.Datum,
    CAST(Kunden.KdNr AS nvarchar) + N'_' + CAST(Vsa.VsaNr AS nvarchar) AS _SPLIT_
  FROM EinzTeil
  JOIN Scans ON Scans.EinzTeilID = EinzTeil.ID
  JOIN VPSPo ON Scans.VPSPoID = VPSPo.ID
  JOIN LsPo ON LsPo.ID = Scans.LsPoID
  JOIN LsKo ON LsKo.ID = LsPo.LsKoID
  JOIN Vsa ON Vsa.ID = LsKo.VsaID
  JOIN Kunden ON Kunden.ID = Vsa.KundenID
  WHERE LsKo.ID IN (SELECT LsKoID FROM #LsForExport)
  ORDER BY LsKo.LsNr;

END;