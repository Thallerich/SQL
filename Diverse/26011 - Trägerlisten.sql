TRY
  DROP TABLE #TmpAusgang;
CATCH ALL END;

SELECT CONVERT(YEAR(Scans.DateTime), SQL_VARCHAR) + '-' + IIF(MONTH(Scans.DateTime) < 10, '0' + CONVERT(MONTH(Scans.DateTime), SQL_VARCHAR), CONVERT(MONTH(Scans.DateTime), SQL_VARCHAR)) AS Monat, Artikel.ArtikelNr, COUNT(DISTINCT Scans.TeileID) AS AnzahlTeile, COUNT(Scans.ID) AS AnzahlAusgang, Teile.TraegerID
INTO #TmpAusgang
FROM Scans, Teile, Vsa, Kunden, Artikel
WHERE Scans.TeileID = Teile.ID
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Artikel.ArtikelNr IN ('201505005530', '202505004010', '202505004230', '202505004450', '202505008010', '202505008410', '202505069501', '202505501011', '202505508230', '202505508450', '202505512010', '202505512220', '202505512230', '202505512450', '203258100701', '203258101301', '203258101402')
  AND Kunden.KdNr = 26011
  AND Scans.LsPoID > 0
  AND Scans.DateTime BETWEEN '01.01.2012 00:00:00' AND '31.12.2012 23:59:59'
GROUP BY Monat, Artikel.ArtikelNr, Teile.TraegerID;

SELECT Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, TraeArch.Menge, Ausgang.AnzahlAusgang, Wochen.Monat1
FROM TraeArch, TraeArti, Traeger, Kunden, KdArti, ViewArtikel Artikel, Wochen, #TmpAusgang Ausgang
WHERE TraeArch.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND TraeArch.KundenID = Kunden.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArch.WochenID = Wochen.ID
  AND Artikel.ArtikelNr = Ausgang.ArtikelNr
  AND Wochen.Monat1 = Ausgang.Monat
  AND Traeger.ID = Ausgang.TraegerID
  AND Kunden.KdNr = 26011
  AND Artikel.ArtikelNr IN ('201505005530', '202505004010', '202505004230', '202505004450', '202505008010', '202505008410', '202505069501', '202505501011', '202505508230', '202505508450', '202505512010', '202505512220', '202505512230', '202505512450', '203258100701', '203258101301', '203258101402')
  AND Wochen.Woche IN ('2012/17', '2012/35', '2012/48')
  AND Artikel.LanguageID = $LANGUAGE$
ORDER BY Wochen.Monat1, Traeger.Traeger, Artikel.ArtikelNr;