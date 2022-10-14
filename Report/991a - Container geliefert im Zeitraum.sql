DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

SELECT FORMAT(@from, N'dd.MM.yyyy', N'de-AT') + N' - ' + FORMAT(@to, N'dd.MM.yyyy', N'de-AT') AS [Auswertungs-Zeitraum], Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], LsKo.LsNr, LsKo.Datum AS Lieferdatum, COUNT(LsCont.ID) AS [Anzahl Container]
FROM LsCont
JOIN LsKo ON LsCont.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Contain ON LsCont.ContainID = Contain.ID
WHERE LsKo.Datum BETWEEN @from AND @to
  AND Kunden.ID IN ($3$)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, LsKo.LsNr, LsKo.Datum
ORDER BY Kunden.KdNr, Vsa.VsaNr, LsKo.Datum;