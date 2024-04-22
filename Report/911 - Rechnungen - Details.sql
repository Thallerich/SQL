SELECT KdGf.KurzBez AS Geschäftsbereich,
  Firma.SuchCode AS Firma,
  Kunden.KdNr,
  Kunden.Debitor AS DebitorNr,
  Kunden.Suchcode AS Kunde,
  RechKo.RechNr AS Rechnungsnummer,
  RechKo.RechDat AS Rechnungsdatum,
  RechKo.FaelligDat AS Fälligkeitsdatum,
  RechKo.NettoWert AS [Netto-Betrag],
  Rechko.MWStSatz AS [MwSt-Satz],
  RechKo.MwStBetrag AS [MwSt-Betrag],
  RechKo.BruttoWert AS [Brutto-Betrag],
  Artikel.ArtikelNr,
  IIF(Artikel.ID > 0, Artikel.ArtikelBez$LAN$, RechPo.Bez) AS [Artikel-/Positionsbezeichnung],
  IIF(RechPo.KdartiID > 0, KdArti.Variante, N'') AS [Variante],
  RechPo.Bez AS [Positionsbezeichnung],
  Artikel.Stueckgewicht AS [Stückgewicht in kg],
  RechPo.Menge AS Positionsmenge,
  RechPo.EPreis AS Einzelpreis,
  RechPo.RabattProz AS [Rabatt in Prozent],
  RechPo.GPreis AS Positionssumme,
  Bereich.Bereich
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN MwSt ON RechKo.MwStID = MwSt.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.FirmaID IN ($1$)
  AND RechKo.RechDat BETWEEN $2$ AND $3$
  AND RechKo.[Status] >= N'N'
  AND RechKo.[Status] < N'X'
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.KdGfID IN ($4$)
  AND Kunden.StandortID IN ($5$);