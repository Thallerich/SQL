SELECT
  TransactionNumber  = N'800',
  ExternalIdentifier = EinzHist.Barcode,
  BundleID           = IIF(Scans.ContainID > 0, Contain.Barcode, (SELECT TOP 1 Contain.Barcode FROM LsCont JOIN Contain ON LsCont.ContainID = Contain.ID WHERE LsCont.LsKoID = LsKo.ID ORDER BY LsCont.ID DESC)),
  CustomerID         = Kunden.KdNr
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Contain ON Scans.ContainID = Contain.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 20156
  AND Vsa.RentomatID = 108
  AND LsKo.Datum > CAST(GETDATE() AS date)
  AND LsKo.[Status] >= 'O'
  AND LsKo.LsKoArtID != (SELECT ID FROM LsKoArt WHERE Art = 'G');