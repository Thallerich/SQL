SELECT Firma.Bez AS Firma, Standort.Bez AS Produzent, StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration], KdGf.KurzBez AS SGF, KdGf.KdGfBez$LAN$ AS [Geschäftsfeld], Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat, SUM(LsPo.Menge) AS Menge, ROUND(SUM(LsPo.Menge * Artikel.StueckGewicht), 2) AS Liefergewicht
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
  AND Kunden.KdGfID IN ($2$)
  AND Standort.ID IN ($3$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.ID > 0
GROUP BY Firma.Bez, Standort.Bez, StandKon.StandKonBez$LAN$, KdGf.KurzBez, KdGf.KdGfBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Bereich.BereichBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT');