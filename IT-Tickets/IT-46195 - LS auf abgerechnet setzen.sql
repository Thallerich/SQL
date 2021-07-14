DECLARE @LsKostenlos TABLE (
  LsKoID int
);

WITH LsKostenlosKunden AS (
  SELECT DISTINCT *
  FROM Salesianer.dbo.__LsKostenlosKunden
)
INSERT INTO @LsKostenlos (LsKoID)
SELECT LsKo.ID
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LsKostenlosKunden ON Kunden.KdNr = LsKostenlosKunden.KdNr
WHERE LsKo.Datum <= LsKostenlosKunden.Datumbis
  AND (LsKo.Status != N'W' OR EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.RechPoID != -2
    )
  );

UPDATE LsKo SET [Status] = N'W', LsKo.MemoIntern = ISNULL(LsKo.MemoIntern, N'') + CHAR(13) + CHAR(10) + N' IT-46195: Lieferscheine als bereits abgerechnet markiert. ThalSt - 2021-03-31'
WHERE ID IN (SELECT LsKoID FROM @LsKostenlos);

UPDATE LsPo SET RechPoID = -2
WHERE LsPo.LsKoID IN (SELECT LsKoID FROM @LsKostenlos)
  AND LsPo.RechPoID < 0
  AND LsPo.RechPoID != -2;