SELECT Firma.Bez AS Firma, Produktion.Bez AS Produzent, Expedition.Bez AS Expedition, ServType.ServTypeBez$LAN$ AS Serviceart, StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration], KdGf.KurzBez AS SGF, KdGf.KdGfBez$LAN$ AS [Geschäftsfeld], Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, Bereich.BereichBez$LAN$ AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Waschpreis as Bearbeitungspreis, KdArti.ID AS KdArtiID, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, KdArti.Umlauf, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat, TRY_CAST(SUM(LsPo.Menge) AS int) AS Menge, Artikel.StueckGewicht AS [Gewicht pro Stück], Artikel.Packmenge AS [VPE-Menge], ME.MeBez$LAN$ AS [VPE], ROUND(SUM(LsPo.Menge * Artikel.StueckGewicht), 2) AS Liefergewicht, SUM(IIF(LsPo.Kostenlos = 0, LsPo.EPreis * LsPo.Menge, 0)) AS Bearbeitungsumsatz
FROM LsPo, LsKo, Vsa, Kunden, Firma, Standort AS Produktion, StandKon, KdGf, KdArti, Artikel, KdBer, Bereich, ME, Fahrt, Touren, Standort AS Expedition,Holding, ServType, STRING_SPLIT($4$, N',') AS ArtiList
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
  AND Kunden.HoldingID = Holding.ID
  AND Touren.ExpeditionID = Expedition.ID
  AND Vsa.ServTypeID = ServType.ID
  AND Kunden.KdGfID IN ($2$)
  AND Produktion.ID IN ($3$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Artikel.ID > 0
  AND LsPo.Menge != 0
  AND Artikel.ArtiTypeID = 1
  AND Holding.ID IN ($5$)
  AND (Artikel.ArtikelNr = RTRIM(LTRIM(ArtiList.[value])) OR LTRIM(ArtiList.value) = N'')
GROUP BY Firma.Bez, Produktion.Bez, Expedition.Bez, ServType.ServTypeBez$LAN$, StandKon.StandKonBez$LAN$, KdGf.KurzBez, KdGf.KdGfBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Holding.Holding, Bereich.BereichBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.ID, KdArti.Waschpreis, KdArti.Variante, KdArti.VariantBez, KdArti.Umlauf, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT'), Artikel.StueckGewicht, Artikel.Packmenge, ME.MeBez$LAN$;