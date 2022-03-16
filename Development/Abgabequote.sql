SELECT KdNr, Kunde, ArtikelNr, Artikelbezeichnung, ROUND(AVG(Menge), 1) AS Durchschnitt, SUM(Menge) AS Umlauf, ROUND(SUM(Ruecklauf), 1) AS Maximum, SUM(Effektiv) AS Effektiv, ROUND(IIF(SUM(Ruecklauf) = 0, 0.0, SUM(Effektiv) * 100 / SUM(Ruecklauf)), 2) AS [Quote %]
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Wochen.Woche, SUM(TraeArch.Menge) AS Menge, SUM(TraeArch.Effektiv) AS Effektiv, IIF(SUM(TraeArch.Menge) < 3, CAST((SUM(TraeArch.Menge) / 3.0) AS numeric(18, 4)), CAST(((SUM(TraeArch.Menge) - 1) / 2.0) AS numeric(18, 4))) AS Ruecklauf
  FROM TraeArch
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Wochen ON TraeArch.WochenID = Wochen.ID
  WHERE Kunden.KdNr IN (10001150, 10000632, 10000714, 202259, 216404, 219157, 2520482, 10004050, 10002032, 218952, 30869, 19152, 271458, 30691, 10002226, 30235, 241179, 30130, 246464, 249119, 262137, 2524108, 2520406, 180337, 30041, 2079, 10000364, 2526034, 190125, 299821, 217098, 180560, 10003795, 246265, 10002836, 30040, 8110, 10001952, 18031, 30129, 245318, 250745, 240025)
    AND Wochen.Woche BETWEEN N'2021/01' AND N'2021/52'
    AND TraeArch.Menge > 0
  GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Wochen.Woche
) AS Ruecklaufdaten
GROUP BY KdNr, Kunde, ArtikelNr, Artikelbezeichnung
ORDER BY KdNr, ArtikelNr;