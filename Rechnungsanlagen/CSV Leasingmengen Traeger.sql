BEGIN TRY
  DROP TABLE #TmpWoche;
END TRY
BEGIN CATCH
END CATCH;

SELECT Wochen.*
INTO #TmpWoche
FROM Wochen
WHERE Wochen.Woche IN (
  SELECT Week.Woche
  FROM Week
  WHERE Week.vonDat >= (SELECT RechKo.vonDatum FROM RechKo WHERE RechKo.ID= $RECHKOID$)
    AND Week.bisDat <= (SELECT RechKo.bisDatum FROM RechKo WHERE RechKo.ID= $RECHKOID$)
);

SELECT Kunde, KSt, Nachname, Vorname, Artikel, SUM(Woche1) AS Woche1, SUM(Woche2) AS Woche2, SUM(Woche3) AS Woche3, SUM(Woche4) AS Woche4, SUM(Woche5) AS Woche5, SUM(Menge) AS Summe
FROM (
  SELECT RTRIM(Kunden.Name1) AS Kunde, RTRIM(Abteil.Bez) AS KSt, Wochen.Woche AS Woche, Traeger.Nachname, Traeger.Vorname, RTRIM(Artikel.ArtikelBez$LAN$) AS Artikel, TraeArch.Menge, IIF(Wochen.Woche = (SELECT Woche FROM #TmpWoche ORDER BY Woche OFFSET 0 ROWS FETCH FIRST 1 ROW ONLY), TraeArch.Menge, 0) AS Woche1, IIF(Wochen.Woche = (SELECT Woche FROM #TmpWoche ORDER BY Woche OFFSET 1 ROWS FETCH FIRST 1 ROW ONLY), TraeArch.Menge, 0) AS Woche2, IIF(Wochen.Woche = (SELECT Woche FROM #TmpWoche ORDER BY Woche OFFSET 2 ROWS FETCH FIRST 1 ROW ONLY), TraeArch.Menge, 0) AS Woche3, IIF(Wochen.Woche = (SELECT Woche FROM #TmpWoche ORDER BY Woche OFFSET 3 ROWS FETCH FIRST 1 ROW ONLY), TraeArch.Menge, 0) AS Woche4, IIF(Wochen.Woche = (SELECT Woche FROM #TmpWoche ORDER BY Woche OFFSET 4 ROWS FETCH FIRST 1 ROW ONLY), TraeArch.Menge, 0) AS Woche5
  FROM TraeArch, Wochen, Kunden, Abteil, TraeArti, Traeger, KdArti, Artikel, Rechko
  WHERE Wochen.ID = TraeArch.WochenID
    AND KdArti.ID = TraeArti.KdArtiID
    AND KdArti.ArtikelID = Artikel.ID
    AND Traeger.ID = TraeArti.TraegerID
    AND TraeArch.TraeArtiID = TraeArti.ID
    AND Kunden.ID = TraeArch.KundenID
    AND Abteil.ID = TraeArch.AbteilID
    AND Kunden.ID = Rechko.KundenID
    AND Rechko.ID = $RECHKOID$
    AND Wochen.Woche IN (SELECT Woche FROM #TmpWoche)
) AS KStelle
GROUP BY Kunde, KSt, Nachname, Vorname, Artikel;