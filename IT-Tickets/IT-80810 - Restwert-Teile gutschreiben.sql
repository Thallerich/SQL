UPDATE _IT80810 SET TeilSoFaID = TeilSofa.ID
FROM _IT80810
JOIN EinzHist ON _IT80810.Barcode COLLATE Latin1_General_CS_AS = EinzHist.Barcode
JOIN TeilSoFa ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
WHERE (_IT80810.Rechnungsnummer = RechKo.RechNr OR _IT80810.Rechnungsnummer IS NULL)
  AND _IT80810.TeilSoFaID IS NULL;

GO

UPDATE TeilSoFa SET [Status] = N'T'
WHERE ID IN (SELECT TeilSoFaID FROM _IT80810)
  AND RechPoID > 0
  AND RechPoGutschriftID = -1
  AND [Status] = N'P';

GO