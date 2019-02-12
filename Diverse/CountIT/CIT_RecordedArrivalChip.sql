USE AdvanTexSync

SELECT FORMAT(CONVERT(date, RecordedDate), 'd', 'de-at') AS RecordedDate, DATEPART(hour, RecordedDate) AS RecordedHour, COUNT(*)
FROM dbo.RecordedArrivalChip
GROUP BY CONVERT(date, RecordedDate), DATEPART(hour, RecordedDate)
ORDER BY RecordedDate, RecordedHour;

GO