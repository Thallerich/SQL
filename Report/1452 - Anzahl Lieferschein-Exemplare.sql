DECLARE @fourweeksago date, @curweekstart date;

SELECT @fourweeksago = [Week].VonDat
FROM [Week]
WHERE DATEADD(week, -4, GETDATE()) BETWEEN [Week].VonDat AND [Week].BisDat;

SELECT @curweekstart = [Week].VonDat
FROM [Week]
WHERE GETDATE() BETWEEN [Week].VonDat AND [Week].BisDat;

SELECT Produktion = CAST(LEFT(STUFF((
    SELECT DISTINCT N', ' + Standort.SuchCode
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    JOIN Standort ON Touren.ExpeditionID = Standort.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
    FOR XML PATH (N'')
  ), 1, 2, N''), 100) AS nvarchar(100)),
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Kunden.AnzKopienLS + Vsa.AnzKopienLS AS [Anzahl Lieferschein-Exemplare],
  [Anzahl Lieferscheine letzte 4 Wochen] = (
    SELECT COUNT(LsKo.ID)
    FROM LsKo
    WHERE LsKo.VsaID = Vsa.ID
      AND LsKo.Datum >= @fourweeksago
      AND LsKo.Datum < @curweekstart
      AND LsKo.[Status] > N'O'
      AND LsKo.DruckZeitpunkt IS NOT NULL
      AND LsKo.DruckMitarbeiID > 0
  )
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.[Status] = N'A'
  AND Vsa.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Touren.ExpeditionID = $1$
  );