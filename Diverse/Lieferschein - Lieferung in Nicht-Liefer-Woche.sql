WITH LsWeek AS (
  SELECT DISTINCT DATEPART(week, LsKo.Datum) AS Woche, DATEPART(year, LsKo.Datum) AS Jahr, LsKo.VsaID
  FROM LsKo
  WHERE LsKo.Datum >= CAST(GETDATE() AS date)
    AND EXISTS (
      SELECT LsPo.*
      FROM LsPo
      WHERE LsPo.LsKoID = LsKo.ID
    )
)
SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN JahrLief ON JahrLief.TableID = Vsa.ID AND JahrLief.TableName = N'VSA'
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND EXISTS (
    SELECT LsWeek.*
    FROM LsWeek
    WHERE LsWeek.VsaID = Vsa.ID
      AND LsWeek.Jahr = JahrLief.Jahr
      AND SUBSTRING(JahrLief.Lieferwochen, LsWeek.Woche, 1) NOT IN (N'X', N'L')
  );