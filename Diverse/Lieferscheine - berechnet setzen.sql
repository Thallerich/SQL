USE Wozabal;
GO

DECLARE @LsInvoiced TABLE (
  LsKoID int,
  LsPoID int
);

INSERT INTO @LsInvoiced
SELECT LsKo.ID AS LsKoID, LsPo.ID AS LsPoID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 60652
  AND LsKo.Status < N'W'
  AND LsPo.RechPoID = -1;

UPDATE LsPo SET LsPo.RechPoID = -2
WHERE LsPo.ID IN (
  SELECT LsPoID
  FROM @LsInvoiced
);

UPDATE LsKo SET LsKo.[Status] = N'W', LsKo.MemoIntern = IIF(LsKo.MemoIntern IS NOT NULL, LsKo.MemoIntern + char(10) + char(13), N'') + N'Lieferschein laut Anforderung MSOF (Ticket IT-17746) per Skript auf berechnet gesetzt!'
WHERE LsKo.iD IN (
  SELECT DISTINCT LsKoID
  FROM @LsInvoiced
);

GO