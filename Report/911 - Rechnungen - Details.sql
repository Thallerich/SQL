SELECT KdGf.KurzBez AS Geschäftsbereich, Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.Debitor AS DebitorNr, Kunden.Suchcode AS Kunde, RechKo.RechNr AS Rechnungsnummer, RechKo.RechDat AS Rechnungsdatum, RechKo.NettoWert AS [Netto-Betrag], MwSt.MWStSatz AS [MwSt-Satz], RechKo.MwStBetrag AS [MwSt-Betrag], RechKo.BruttoWert AS [Brutto-Betrag], Artikel.ArtikelNr, IIF(Artikel.ID > 0, Artikel.ArtikelBez, RechPo.Bez) AS [Artikel-/Positionsbezeichnung], RechPo.Menge AS Positionsmenge, RechPo.EPreis AS Einzelpreis, RechPo.RabattProz AS [Rabatt in Prozent], RechPo.GPreis AS Positionssumme
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN MwSt ON RechKo.MwStID = MwSt.ID
LEFT JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
LEFT JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.FirmaID IN ($1$)
  AND RechKo.RechDat BETWEEN $2$ AND $3$
  AND RechKo.Status BETWEEN N'F' AND N'S';