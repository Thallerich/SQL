SELECT Firma.SuchCode AS Firma,
  Kunden.KdNr,
  Kunden.Debitor,
  Kunden.SuchCode AS Kunde,
  KdGf.KurzBez AS Geschäftsbereich,
  RechKo.RechNr AS Rechnungsnummer,
  RechKo.RechDat AS Rechnungsdatum,
  FORMAT(RechKo.RechDat, N'yyyy-MM', N'de-AT') AS Periode,
  FibuExp.Zeitpunkt AS [Übergabezeitpunkt FIBU],
  Wae.IsoCode AS Währung,
  RechKo.BruttoWert,
  RechKo.NettoWert,
  RechKo.MwStBetrag,
  RechKo.RundungBetrag,
  FibuNr = 
  CASE
    WHEN Firma.SuchCode = N'UKLU' THEN CAST(93 AS nchar(3))
    WHEN Firma.SuchCode = N'SMW' AND Standort.SuchCode = N'UKLU' THEN CAST(90 AS nchar(3))  --Salesianer SÜD
    WHEN Firma.SuchCode = N'SMW' AND Standort.SuchCode <> N'UKLU' THEN CAST(40 AS nchar(3))  --Salesianer WEST
    WHEN Firma.SuchCode = N'SMBU' THEN CAST(895 AS nchar(3))
    ELSE CAST(KdGf.FibuNr AS nchar(3))
  END,
  Kostenträger = 
  CASE
    WHEN Konten.Konto = N'480004' AND KdGf.KurzBez = N'JOB' THEN N'1400'
    WHEN Konten.Konto = N'480004' AND KdGf.KurzBez = N'MED' THEN N'2400'
    WHEN Konten.Konto = N'480004' AND KdGf.KurzBez = N'GAST' THEN N'1310'
    ELSE RechPo.KsSt
  END,
  SUM(RechPo.GPreis) AS Positionsbetrag
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Konten ON RechPo.KontenID = Konten.ID
JOIN FibuExp ON RechKo.FibuExpID = FibuExp.ID
JOIN Wae ON RechKo.WaeID = Wae.ID
WHERE RechKo.RechDat >= N'2019-04-01'
  AND RechKo.FibuExpID > 0
GROUP BY Firma.SuchCode, Kunden.KdNr, Kunden.Debitor, Kunden.SuchCode, KdGf.KurzBez, RechKo.RechNr, RechKo.RechDat, FORMAT(RechKo.RechDat, N'yyyy-MM', N'de-AT'), FibuExp.Zeitpunkt, Wae.IsoCode, RechKo.BruttoWert, RechKo.NettoWert, RechKo.MwStBetrag, RechKo.RundungBetrag,
  CASE
    WHEN Firma.SuchCode = N'UKLU' THEN CAST(93 AS nchar(3))
    WHEN Firma.SuchCode = N'SMW' AND Standort.SuchCode = N'UKLU' THEN CAST(90 AS nchar(3))  --Salesianer SÜD
    WHEN Firma.SuchCode = N'SMW' AND Standort.SuchCode <> N'UKLU' THEN CAST(40 AS nchar(3))  --Salesianer WEST
    WHEN Firma.SuchCode = N'SMBU' THEN CAST(895 AS nchar(3))
    ELSE CAST(KdGf.FibuNr AS nchar(3))
  END,
  CASE
    WHEN Konten.Konto = N'480004' AND KdGf.KurzBez = N'JOB' THEN N'1400'
    WHEN Konten.Konto = N'480004' AND KdGf.KurzBez = N'MED' THEN N'2400'
    WHEN Konten.Konto = N'480004' AND KdGf.KurzBez = N'GAST' THEN N'1310'
    ELSE RechPo.KsSt
  END;  