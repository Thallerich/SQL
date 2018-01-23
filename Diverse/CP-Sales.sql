SELECT RTRIM(Kunden.Debitor) AS Kundennummer, 
  RTRIM(Kunden.SuchCode) AS Kundenname, 
  SGF = 
    CASE KdGf.FibuNr
      WHEN 10 THEN N'GP'
      WHEN 30 THEN N'IP'
      WHEN 40 THEN IIF(Firma.SuchCode = N'42', N'HO BHG', N'HO')
      WHEN 50 THEN N'ÖS'
      WHEN 70 THEN N'CZ'
      WHEN 80 THEN N'TL'
        ELSE N'XX'
    END,
  Kundengruppe = 
    CASE KdGf.KurzBez
      WHEN N'CZ' THEN RTRIM(KdGrp.Nr)
      WHEN N'ÖS' THEN RTRIM(Branche.Branche)
      ELSE RTRIM(KdGf.KurzBez)
    END,
  RTRIM(IIF(Holding.ID = -1, N'', Holding.Holding)) AS Holding, 
  N'' AS Kundenart, 
  N'' AS Betreuer, 
  IIF(Artikel.ID = -1, N'kein ' + RTRIM(Konten.Konto), RTRIM(Artikel.ArtikelNr)) AS Artikelnummer, 
  IIF(Artikel.ID = -1, N'kein ' + RTRIM(Konten.Konto), RTRIM(Artikel.ArtikelBez)) AS Artikelname, 
  N'' AS Artikelgruppe,
  RTRIM(Konten.Konto) AS Erloeskonto,
  IIF(Kunden.KdNr = 60400 AND Konten.Konto = 4170 AND RechKo.RechDat BETWEEN N'2016-02-01' AND '2016-07-31', N'122184', RIGHT(RTRIM(Firma.SuchCode) + RTRIM(RechPo.KsSt), 6)) AS Kostenstelle,
  IIF(Kunden.KdNr = 60400 AND RechKo.RechDat BETWEEN N'2016-02-01' AND N'2016-07-31', N'12', RTRIM(Standort.FibuNr)) AS Produktion,
  RechKo.RechNr AS RechnungsNr, 
  FORMAT(RechKo.RechDat, 'yyyy-MM', 'de-at') AS Buchungsperiode,
  RTRIM(Wae.IsoCode) AS [Währung],
  RechPo.GPreis AS Umsatz,
  IIF(RPoType.StatistikGruppe IN (N'Bearbeitung', N'Leasing'), RechPo.Epreis, 0) AS Preis,
  IIF(RPoType.StatistikGruppe = N'Bearbeitung', RechPo.Menge, 0) AS LiefermengeStueck,
  IIF(RPoType.StatistikGruppe = N'Bearbeitung', RechPo.Menge * Artikel.StueckGewicht, 0) AS LiefermengeKG,
  IIF(RPoType.StatistikGruppe = N'Leasing', RechPo.Menge, 0) AS BestandsmengeStueck
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Konten ON RechPo.KontenID = Konten.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON (StandBer.StandKonID = StandKon.ID AND RechPo.BereichID = StandBer.BereichID)
JOIN Standort ON StandBer.ProduktionID = Standort.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
JOIN Wae ON RechKo.WaeID = Wae.ID
LEFT OUTER JOIN (
  SELECT KdGru.KundenID, AdrGrp.Nr
  FROM KdGru, AdrGrp
  WHERE KdGru.AdrGrpID = AdrGrp.ID
  AND AdrGrp.Nr IN (N'HO', N'GW', N'IG', N'SH')
) KdGrp ON KdGrp.KundenID = Kunden.ID
WHERE RechKo.RechDat BETWEEN CAST(N'2017-02-01' AS date) AND CAST(N'2017-06-30' AS date)
AND RechKo.FibuExpID > 0;