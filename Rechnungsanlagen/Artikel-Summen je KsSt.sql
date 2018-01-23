SELECT TRIM(Abteil.Abteilung) + ' ' + TRIM(Abteil.Bez) AS Kostenstelle, TRIM(Artikel.ArtikelNr) + ' ' + TRIM(Artikel.ArtikelBez$LAN$) AS Artikel, RechPo.Menge AS [verrechnete Menge], RechPo.GPreis AS Umsatz
FROM RechPo, RechKo, Abteil, KdArti, Artikel
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND RechKo.ID = $RECHKOID$
  AND RechPo.KdArtiID > 0

UNION ALL

SELECT TRIM(Abteil.Abteilung) + ' ' + TRIM(Abteil.Bez) AS Kostenstelle, 'Summe' AS Artikel, SUM(RechPo.Menge) AS [verrechnete Menge], SUM(RechPo.GPreis) AS Umsatz
FROM RechPo, RechKo, Abteil, KdArti, Artikel
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND RechKo.ID = $RECHKOID$
  AND RechPo.KdArtiID > 0
GROUP BY Abteil.Abteilung, Abteil.Bez

ORDER BY Kostenstelle, Artikel;