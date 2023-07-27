SELECT Firma.Bez AS Firma, Produktion.Bez AS Produzent, Expedition.Bez AS Expedition, ServType.ServTypeBez$LAN$ AS Serviceart, StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration], KdGf.KurzBez AS SGF, KdGf.KdGfBez$LAN$ AS [Geschäftsfeld], Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat, SUM(LsPo.Menge) AS Menge, Artikel.StueckGewicht AS [Gewicht pro Stück], Artikel.Packmenge AS [VPE-Menge], ME.MeBez$LAN$ AS [VPE], ROUND(SUM(LsPo.Menge * Artikel.StueckGewicht), 2) AS Liefergewicht
FROM LsPo, LsKo, Vsa, Kunden, Firma, Standort AS Produktion, StandKon, KdGf, KdArti, Artikel, KdBer, Bereich, ME, Fahrt, Touren, Standort AS Expedition, ServType, STRING_SPLIT($4$, N',') AS ArtiList
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
  AND LsPo.ProduktionID = Produktion.ID
  AND Vsa.StandKonID = StandKon.ID
  AND Kunden.KdGfID = KdGf.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Artikel.MEID = ME.ID
  AND LsKo.FahrtID = Fahrt.ID
  AND Fahrt.TourenID = Touren.ID
  AND Touren.ExpeditionID = Expedition.ID
  AND Vsa.ServTypeID = ServType.ID
  AND Kunden.KdGfID IN ($2$)
  AND Produktion.ID IN ($3$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.ID > 0
  AND LsPo.Menge != 0
  AND Artikel.ArtiTypeID = 1
  AND (Artikel.ArtikelNr = LTRIM(ArtiList.[value]) OR LTRIM(ArtiList.value) = N'')
GROUP BY Firma.Bez, Produktion.Bez, Expedition.Bez, ServType.ServTypeBez$LAN$, StandKon.StandKonBez$LAN$, KdGf.KurzBez, KdGf.KdGfBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Bereich.BereichBez$LAN$, Artikel.ArtikelNr, KdArti.Variante, KdArti.VariantBez, Artikel.ArtikelBez$LAN$, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT'), Artikel.StueckGewicht, Artikel.Packmenge, ME.MeBez$LAN$;