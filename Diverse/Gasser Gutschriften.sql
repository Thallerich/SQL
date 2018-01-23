-- 623 - Bereich / Kunden

TRY
  DROP TABLE #TmpGasser;
CATCH ALL END;

SELECT Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(TRIM(Bereich.Bez),' 15%'), TRIM(Bereich.Bez)) AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 70), SQL_MONEY) AS Gasser, CONVERT(IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 15, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 30), SQL_MONEY) AS Wozabal  
INTO #TmpGasser  
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich IN ('SH', 'IK', 'TW', 'EW', 'EWB')
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez,Kdarti.Variante

UNION

SELECT Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, TRIM(Bereich.Bez) + ' 14,28%' AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85.72, SQL_MONEY) AS Gasser, CONVERT(SUM(LsPo.Menge * LsPo.EPreis) / 100 * 14.28, SQL_MONEY) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Kunden.KdNr IN (30291, 30341)
  AND Vsa.SuchCode = '490'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez,Kdarti.Variante
ORDER BY Kunden.KdNr, Bereich.Bereich;

SELECT Gasser.KdNr, Gasser.SuchCode, Gasser.Bereich, Gasser.BereichBez, Gasser.LsMenge, Gasser.RechSum, Gasser.Gasser, Gasser.Wozabal
FROM #TmpGasser Gasser

UNION

SELECT 999999 AS KdNr, 'Summe:' AS SuchCode, '' AS Bereich, '' AS BereichBez, SUM(Gasser.LsMenge) AS LsMenge, SUM(Gasser.RechSum) AS RechSum, SUM(Gasser.Gasser) AS Gasser, SUM(Gasser.Wozabal) AS Wozabal
FROM #TmpGasser Gasser;

-- 624 - Bereich / Artikel

TRY
  DROP TABLE #TmpGasser;
CATCH ALL END;

SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(TRIM(Bereich.Bez),' 15%'), TRIM(Bereich.Bez)) AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 70), SQL_MONEY) AS Gasser, CONVERT(IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 15, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 30), SQL_MONEY) AS Wozabal  
INTO #TmpGasser  
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich IN ('SH', 'IK', 'TW', 'EW', 'EWB')
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.Bereich, Bereich.Bez,Kdarti.Variante

UNION

SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.Bereich, TRIM(Bereich.Bez) + ' 14,28%' AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85.72, SQL_MONEY) AS Gasser, CONVERT(SUM(LsPo.Menge * LsPo.EPreis) / 100 * 14.28, SQL_MONEY) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Kunden.KdNr IN (30291, 30341)
  AND Vsa.SuchCode = '490'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.Bereich, Bereich.Bez,Kdarti.Variante
ORDER BY Kunden.KdNr, Artikel.ArtikelNr, Bereich.Bereich;

SELECT Gasser.KdNr, Gasser.SuchCode, Gasser.ArtikelNr, Gasser.ArtikelBez, Gasser.Bereich, Gasser.BereichBez, Gasser.LsMenge, Gasser.RechSum, Gasser.Gasser, Gasser.Wozabal
FROM #TmpGasser Gasser

UNION

SELECT 999999 AS KdNr, 'Summe:' AS SuchCode, '' AS ArtikelNr, '' AS ArtikelBez, '' AS Bereich, '' AS BereichBez, SUM(Gasser.LsMenge) AS LsMenge, SUM(Gasser.RechSum) AS RechSum, SUM(Gasser.Gasser) AS Gasser, SUM(Gasser.Wozabal) AS Wozabal
FROM #TmpGasser Gasser;




/*
UNION

SELECT Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich,  IIF(Kdarti.Variante='G',CONCAT(TRIM(Bereich.Bez),' 15%'),TRIM(Bereich.Bez)) AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(IIF(Kdarti.Variante='G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 70), SQL_MONEY) AS Gasser, CONVERT(IIF(Kdarti.Variante  ='G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 15, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 30), SQL_MONEY) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich IN ('EW')
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez,Kdarti.Variante

UNION

SELECT Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(SUM(LsPo.Menge * LsPo.EPreis) / 100 * 70, SQL_MONEY) AS Gasser, CONVERT(SUM(LsPo.Menge * LsPo.EPreis) / 100 * 30, SQL_MONEY) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich IN ('BK', 'BW')
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez

UNION

SELECT Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(SUM(LsPo.Menge * LsPo.EPreis), SQL_MONEY) AS RechSum, CONVERT(-1, SQL_MONEY) AS Gasser, CONVERT(-1, SQL_MONEY) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdBer, ViewBereich Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.SichtbarID = 51  
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich NOT IN ('SH', 'IK', 'EW', 'BK', 'BW', 'TW')
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.Bereich, Bereich.Bez
ORDER BY Kunden.KdNr, Bereich.Bereich;*/