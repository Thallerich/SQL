SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Nachname, ISNULL(Traeger.Vorname, N'') AS Vorname, ISNULL(Traeger.Titel, N'') AS Titel, FORMAT(SUM(TraeArch.Menge * AbtKdArW.EPreis), N'C', N'de-AT') AS [Leasing berechnet]
FROM TraeArch
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN AbtKdArW ON TraeArch.AbtKdArWID = AbtKdArW.ID
WHERE Kunden.KdNr = 30391
  AND LEFT(Wochen.Monat1, 4) = N'2017'
  AND TraeArch.Kostenlos = 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Traeger.Titel
ORDER BY Kunden.KdNr, Traeger.Nachname, Traeger.Vorname;