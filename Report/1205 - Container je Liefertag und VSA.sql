SELECT LsKo.Datum AS Lieferdatum, Touren.Tour AS Liefertour, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktion, COUNT(DISTINCT LsCont.ContainID) AS [Anzahl Container]
FROM LsCont
JOIN LsKo ON LsCont.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Standort AS Produktion ON LsKo.ProduktionID = Produktion.ID
WHERE LsKo.Datum >= $STARTDATE$ AND LsKo.Datum <= $ENDDATE$
  AND LsKo.ProduktionID IN ($2$)
GROUP BY LsKo.Datum, Touren.Tour, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Produktion.Bez
ORDER BY Lieferdatum, KdNr, VsaNr;