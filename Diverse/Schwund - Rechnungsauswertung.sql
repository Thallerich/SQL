SELECT KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.Debitor, Kunden.SuchCode AS Kunde, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, RKoType.RKoTypeBez AS Rechnungstyp, RechKo.Memo AS Rechnungsbemerkung, RechKo.BruttoWert, RechKo.MwStBetrag, RechKo.NettoWert
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN RKoType ON RechKo.RKoTypeID = RKoType.ID
WHERE KdGf.KurzBez = N'MED'
  AND (RKoType.RKoTypeBez = N'Schwundverrechnung UHF-Pool' OR UPPER(RechKo.Memo) LIKE N'%SCHWUND%')
  AND RechKo.RechDat >= N'2018-04-01'
  AND RechKo.Status = N'F';