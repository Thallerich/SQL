WITH DateDay AS (
  SELECT CAST(GETDATE() AS date) AS Datum, dbo.advFunc_DoWInt(GETDATE()) AS DayNumber
  UNION ALL
  SELECT DATEADD(day, -1, Datum) AS Datum, dbo.advFunc_DoWInt(DATEADD(day, -1, DAtum))
  FROM DateDay
  WHERE DATEADD(day, -1, Datum) > DATEADD(day, -7, CAST(GETDATE() AS date))
)
SELECT KdNr, Kunde, VsaNr, [Vsa-Bezeichnung], [1] AS [Liefertag Montag], [2] AS [Liefertag Dienstag], [3] AS [Liefertag Mittwoch], [4] AS [Liefertag Donnerstag], [5] AS [Liefertag Freitag], [6] AS [Liefertag Samstag], [7] AS [Liefertag Sonntag]
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Touren.Wochentag,
    WochentagBereitstellung = 
      CASE dbo.advFunc_DoWInt(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(DateDay.Datum AS datetime)))
        WHEN 1 THEN N'Montag'
        WHEN 2 THEN N'Dienstag'
        WHEN 3 THEN N'Mittwoch'
        WHEN 4 THEN N'Donnerstag'
        WHEN 5 THEN N'Freitag'
        WHEN 6 THEN N'Samstag'
        WHEN 7 THEN N'Sonntag'
        ELSE NULL
      END
  FROM VsaTour
  JOIN Vsa ON VsaTour.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN TourPrio ON Touren.TourPrioID = TourPrio.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
  JOIN DateDay ON Touren.Wochentag = DateDay.DayNumber
  WHERE Bereich.Bereich = N'ST'
    AND Vsa.Status = N'A'
    AND Kunden.Status = N'A'
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
    AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
) AS VorlaufDaten
PIVOT (
  MAX(WochentagBereitstellung) FOR Wochentag IN ([1], [2], [3], [4], [5], [6], [7])
) AS VorlaufPivot
ORDER BY KdNr ASC, VsaNr ASC;