DROP TABLE IF EXISTS #TmpGasser;

SELECT LsDaten.KdNr, LsDaten.SuchCode, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(RTRIM(Bereich.BereichBez$LAN$),' 15%'), IIF(KdArti.Variante = 'Z', CONCAT(RTRIM(Bereich.BereichBez$LAN$), ' 100%'), RTRIM(Bereich.BereichBez$LAN$))) AS BereichBez, SUM(LsDaten.Menge) AS LsMenge, LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2 AS RabattSkonto, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis)) AS RechSum, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2)) AS RabattSum, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 85, IIF(KdArti.Variante = 'Z', SUM(LsDaten.Menge * LsDaten.EPreis), SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 70)) - (IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 85, IIF(KdArti.Variante = 'Z', SUM(LsDaten.Menge * LsDaten.EPreis), SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 70)) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2))) AS Gasser, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 15, IIF(KdArti.Variante = 'Z', 0, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 30)) - (IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 15, IIF(KdArti.Variante = 'Z', 0, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 30)) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2))) AS Wozabal
INTO #TmpGasser
FROM KdArti, Artikel, KdBer, Bereich, ZahlZiel, (
  SELECT LsKo.VsaID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.Menge, LsPo.EPreis, Kunden.ZahlZielID, Kunden.KdNr, Kunden.SuchCode, Kunden._ManRabatt
  FROM LsPo, LsKo, Vsa, Kunden
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.StandortID = (SELECT ID FROM Standort WHERE Bez = N'Gasser')
    AND LsKo.Datum BETWEEN $1$ AND $2$
    AND Kunden.KdNr NOT IN (30974)
) AS LsDaten
WHERE LsDaten.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND LsDaten.ZahlZielID = ZahlZiel.ID
  AND Bereich.Bereich IN ('FW', 'IK', 'TW', 'LW')
  AND LsDaten.Kostenlos = 0
GROUP BY LsDaten.KdNr, LsDaten.SuchCode, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(RTRIM(Bereich.BereichBez$LAN$),' 15%'), IIF(KdArti.Variante = 'Z', CONCAT(RTRIM(Bereich.BereichBez$LAN$), ' 100%'), RTRIM(Bereich.BereichBez$LAN$))), Kdarti.Variante, LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2

UNION ALL

SELECT LsDaten.KdNr, LsDaten.SuchCode, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(RTRIM(Bereich.BereichBez$LAN$),' 15%'), IIF(KdArti.Variante = 'Z', CONCAT(RTRIM(Bereich.BereichBez$LAN$), ' 100%'), RTRIM(Bereich.BereichBez$LAN$))) AS BereichBez, SUM(LsDaten.Menge) AS LsMenge, LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2 AS RabattSkonto, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis)) AS RechSum, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2)) AS RabattSum, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 85, IIF(KdArti.Variante = 'Z', SUM(LsDaten.Menge * LsDaten.EPreis), SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 75)) - (IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 85, IIF(KdArti.Variante = 'Z', SUM(LsDaten.Menge * LsDaten.EPreis), SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 75)) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2))) AS Gasser, CONVERT(money, IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 15, IIF(KdArti.Variante = 'Z', 0, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 25)) - (IIF(Kdarti.Variante = 'G', SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 15, IIF(KdArti.Variante = 'Z', 0, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 25)) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2))) AS Wozabal
FROM KdArti, Artikel, KdBer, Bereich, ZahlZiel, (
  SELECT LsKo.VsaID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.Menge, LsPo.EPreis, Kunden.ZahlZielID, Kunden.KdNr, Kunden.SuchCode, Kunden._ManRabatt
  FROM LsPo, LsKo, Vsa, Kunden
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.StandortID = (SELECT ID FROM Standort WHERE Bez = N'Gasser')
    AND LsKo.Datum BETWEEN $1$ AND $2$
    AND Kunden.KdNr IN (30974)
) AS LsDaten
WHERE LsDaten.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND LsDaten.ZahlZielID = ZahlZiel.ID
  AND Bereich.Bereich IN ('FW', 'IK', 'TW', 'LW')
  AND LsDaten.Kostenlos = 0
GROUP BY LsDaten.KdNr, LsDaten.SuchCode, Bereich.Bereich, IIF(Kdarti.Variante = 'G', CONCAT(RTRIM(Bereich.BereichBez$LAN$),' 15%'), IIF(KdArti.Variante = 'Z', CONCAT(RTRIM(Bereich.BereichBez$LAN$), ' 100%'), RTRIM(Bereich.BereichBez$LAN$))), Kdarti.Variante, LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2

UNION ALL

SELECT LsDaten.KdNr, LsDaten.SuchCode, Bereich.Bereich, RTRIM(Bereich.BereichBez$LAN$) + ' 14,28%' AS BereichBez, SUM(LsDaten.Menge) AS LsMenge, LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2 AS RabattSkonto, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis)) AS RechSum, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2)) AS RabattSum, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 85.72 - (SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 85.72) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2)) AS Gasser, CONVERT(money, SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 14.28 - (SUM(LsDaten.Menge * LsDaten.EPreis) / 100 * 14.28) / 100 * (LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2)) AS Wozabal
FROM KdArti, Artikel, KdBer, Bereich, ZahlZiel, (
  SELECT LsKo.VsaID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.Menge, LsPo.EPreis, Kunden.ZahlZielID, Kunden.KdNr, Kunden.SuchCode, Kunden._ManRabatt
  FROM LsPo, LsKo, Vsa, Kunden
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr IN (30291, 30341)
    AND Vsa.SuchCode = '490'
    AND LsKo.Datum BETWEEN $1$ AND $2$
) AS LsDaten
WHERE LsDaten.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND LsDaten.ZahlZielID = ZahlZiel.ID
GROUP BY LsDaten.KdNr, LsDaten.SuchCode, Bereich.Bereich, Bereich.BereichBez$LAN$, Kdarti.Variante, LsDaten._ManRabatt + KdBer.RabattWasch + ZahlZiel.Skonto * 1.2
ORDER BY LsDaten.KdNr, Bereich.Bereich;

SELECT Gasser.KdNr, Gasser.SuchCode, Gasser.Bereich, Gasser.BereichBez, Gasser.LsMenge, Gasser.RabattSkonto, Gasser.RechSum, Gasser.RabattSum, Gasser.Gasser, Gasser.Wozabal
FROM #TmpGasser Gasser

UNION

SELECT Gasser.KdNr AS KdNr, 'Summe ' + RTRIM(Gasser.SuchCode) AS SuchCode, 'ZZZ' AS Bereich, '' AS BereichBez, SUM(Gasser.LsMenge) AS LsMenge, 0 AS RabattSkonto, SUM(Gasser.RechSum) AS RechSum, SUM(Gasser.RabattSum) AS RabattSum, SUM(Gasser.Gasser) AS Gasser, SUM(Gasser.Wozabal) AS Wozabal
FROM #TmpGasser Gasser
GROUP BY Gasser.KdNr, Gasser.SuchCode

UNION

SELECT 999999 AS KdNr, 'Summe:' AS SuchCode, '' AS Bereich, '' AS BereichBez, SUM(Gasser.LsMenge) AS LsMenge, 0 AS RabattSkonto, SUM(Gasser.RechSum) AS RechSum, SUM(Gasser.RabattSum) AS RabattSum, SUM(Gasser.Gasser) AS Gasser, SUM(Gasser.Wozabal) AS Wozabal
FROM #TmpGasser Gasser
ORDER BY KdNr, Bereich;