SELECT Firma.Bez AS Firma, Standort.Bez AS Produzent, StandKon.Bez AS [Standort-Konfiguration], KdGf.KurzBez AS SGF, KdGf.Bez AS [Geschäftsfeld], Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, DATEPART(month, LsKo.Datum) AS Monat, SUM(LsPo.Menge) AS Menge, ROUND(SUM(LsPo.Menge * Artikel.StueckGewicht), 2) AS Liefergewicht
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
  AND Kunden.KdGfID IN ($3$)
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND Artikel.ID > 0
GROUP BY Firma.Bez, Standort.Bez, StandKon.Bez, KdGf.KurzBez, KdGf.Bez, Kunden.KdNr, Kunden.SuchCode, Bereich.BereichBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, DATEPART(month, LsKo.Datum);