SELECT KdGf.KurzBez AS SGF, KdGf.KdGfBez$LAN$ AS [Geschäftsfeld], Kunden.KdNr, Kunden.SuchCode AS Kunde, CONVERT(char(4), DATEPART(year, LsKo.Datum)) + '/' + IIF(DATEPART(month, LsKo.Datum) < 10, '0' + CONVERT(char(1), DATEPART(month, LsKo.Datum)), CONVERT(char(2), DATEPART(month, LsKo.Datum))) AS Monat, Bereich.BereichBez$LAN$ AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(LsPo.Menge) AS Menge, ROUND(SUM(LsPo.Menge * Artikel.StueckGewicht), 2) AS Liefergewicht
FROM LsPo, LsKo, Vsa, Kunden, Firma, Standort, StandKon, KdGf, KdArti, Artikel, KdBer, Bereich
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
	AND LsPo.ProduktionID = Standort.ID
	AND Vsa.StandKonID = StandKon.ID
	AND Kunden.KdGfID = KdGf.ID
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND KdArti.KdBerID = KdBer.ID
	AND KdBer.BereichID = Bereich.ID
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND Artikel.ID > 0
GROUP BY KdGf.KurzBez, KdGf.KdGfBez$LAN$, Kunden.KdNr, Kunden.SuchCode, CONVERT(char(4), DATEPART(year, LsKo.Datum)) + '/' + IIF(DATEPART(month, LsKo.Datum) < 10, '0' + CONVERT(char(1), DATEPART(month, LsKo.Datum)), CONVERT(char(2), DATEPART(month, LsKo.Datum))), Bereich.BereichBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Monat, Kundenbereich, Artikel.ArtikelNr;