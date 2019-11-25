SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Traeger.Indienst, WeekIn.VonDat AS WeekInDat, Traeger.Ausdienst, WeekOut.VonDat AS WeekOutDat, DATEDIFF(week, WeekIn.VonDat, WeekOut.VonDat) AS [Abmeldung nach x Wochen]
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Week AS WeekIn ON WeekIn.Woche = Traeger.Indienst
JOIN Week AS WeekOut ON WeekOut.Woche = Traeger.Ausdienst
WHERE Traeger.Ausdienst IS NOT NULL
  AND Traeger.Ausdienst >= N'2019/01'
  AND Traeger.Ausdienst > Traeger.Indienst
  AND DATEDIFF(week, WeekIn.VonDat, WeekOut.VonDat) <= 3