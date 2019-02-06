DROP TABLE IF EXISTS #TmpGasser;

SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(RTRIM(Bereich.BereichBez$LAN$),' 15%'), IIF(KdArti.Variante = 'Z', CONCAT(RTRIM(Bereich.BereichBez$LAN$), ' 100%'), RTRIM(Bereich.BereichBez$LAN$))) AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(money, SUM(LsPo.Menge * LsPo.EPreis)) AS RechSum, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85, IIF(KdArti.Variante = 'Z', SUM(LsPo.Menge * LsPo.EPreis), SUM(LsPo.Menge * LsPo.EPreis) / 100 * 70))) AS Gasser, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 15, IIF(KdArti.Variante = 'Z', 0, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 30))) AS Wozabal
INTO #TmpGasser
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, KdBer, Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Kunden.SichtbarID = 51
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich IN ('SH', 'IK', 'TW', 'EW', 'EWB')
  AND LsPo.Kostenlos = 0
  AND Kunden.KdNr NOT IN (30974)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.Bereich, Bereich.BereichBez$LAN$, Kdarti.Variante

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(RTRIM(Bereich.BereichBez$LAN$),' 15%'), IIF(KdArti.Variante = 'Z', CONCAT(RTRIM(Bereich.BereichBez$LAN$), ' 100%'), RTRIM(Bereich.BereichBez$LAN$))) AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(money, SUM(LsPo.Menge * LsPo.EPreis)) AS RechSum, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85, IIF(KdArti.Variante = 'Z', SUM(LsPo.Menge * LsPo.EPreis), SUM(LsPo.Menge * LsPo.EPreis) / 100 * 75))) AS Gasser, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsPo.Menge * LsPo.EPreis) / 100 * 15, IIF(KdArti.Variante = 'Z', 0, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 25))) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, KdBer, Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Kunden.SichtbarID = 51
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Bereich.Bereich IN ('SH', 'IK', 'TW', 'EW', 'EWB')
  AND LsPo.Kostenlos = 0
  AND Kunden.KdNr IN (30974)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.Bereich, Bereich.BereichBez$LAN$, Kdarti.Variante

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.Bereich, RTRIM(Bereich.BereichBez$LAN$) + ' 14,28%' AS BereichBez, SUM(LsPo.Menge) AS LsMenge, CONVERT(money, SUM(LsPo.Menge * LsPo.EPreis)) AS RechSum, CONVERT(money, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 85.72) AS Gasser, CONVERT(money, SUM(LsPo.Menge * LsPo.EPreis) / 100 * 14.28) AS Wozabal
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, KdBer, Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Kunden.SichtbarID = 51
  AND LsKo.Datum BETWEEN $1$ AND $2$ -- Datumsbereich, welche Lieferscheine berücksichtigt werden
  AND Kunden.KdNr IN (30291, 30341)
  AND Vsa.SuchCode = '490'
  AND LsPo.Kostenlos = 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.Bereich, Bereich.BereichBez$LAN$, Kdarti.Variante
ORDER BY Kunden.KdNr, Artikel.ArtikelNr, Bereich.Bereich;

SELECT Gasser.KdNr, Gasser.SuchCode, Gasser.ArtikelNr, Gasser.ArtikelBez, Gasser.Bereich, Gasser.BereichBez, Gasser.LsMenge, Gasser.RechSum, Gasser.Gasser, Gasser.Wozabal
FROM #TmpGasser Gasser

UNION

SELECT 999999 AS KdNr, 'Summe:' AS SuchCode, '' AS ArtikelNr, '' AS ArtikelBez, '' AS Bereich, '' AS BereichBez, SUM(Gasser.LsMenge) AS LsMenge, SUM(Gasser.RechSum) AS RechSum, SUM(Gasser.Gasser) AS Gasser, SUM(Gasser.Wozabal) AS Wozabal
FROM #TmpGasser Gasser;