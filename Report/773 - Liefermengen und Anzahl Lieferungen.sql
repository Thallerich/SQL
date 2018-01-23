-- ####################################################################################
-- Pipeline: AnzLS
-- ####################################################################################

SELECT CONVERT(char(4), DATEPART(year, LsKo.Datum)) + IIF(DATEPART(week, LsKo.Datum) < 10, '/0' + CONVERT(char(1), DATEPART(week, LsKo.Datum)), '/' + CONVERT(char(2), DATEPART(week, LsKo.Datum))) AS Woche, Vsa.SuchCode, Vsa.Bez, COUNT(DISTINCT LsKo.LsNr) AS AnzLS
FROM LsPo, LsKo, Vsa, Kunden
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $1$ AND $2$
GROUP BY CONVERT(char(4), DATEPART(year, LsKo.Datum)) + IIF(DATEPART(week, LsKo.Datum) < 10, '/0' + CONVERT(char(1), DATEPART(week, LsKo.Datum)), '/' + CONVERT(char(2), DATEPART(week, LsKo.Datum))), Vsa.SuchCode, Vsa.Bez
ORDER BY Woche, Vsa.SuchCode;

-- ####################################################################################
-- Pipeline: Liefermengen
-- ####################################################################################

SELECT CONVERT(char(4), DATEPART(year, LsKo.Datum)) + IIF(DATEPART(week, LsKo.Datum) < 10, '/0' + CONVERT(char(1), DATEPART(week, LsKo.Datum)), '/' + CONVERT(char(2), DATEPART(week, LsKo.Datum))) AS Woche, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(Menge) AS Menge
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $1$ AND $2$
GROUP BY CONVERT(char(4), DATEPART(year, LsKo.Datum)) + IIF(DATEPART(week, LsKo.Datum) < 10, '/0' + CONVERT(char(1), DATEPART(week, LsKo.Datum)), '/' + CONVERT(char(2), DATEPART(week, LsKo.Datum))), Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Woche, Vsa.SuchCode, Artikel.ArtikelNr;