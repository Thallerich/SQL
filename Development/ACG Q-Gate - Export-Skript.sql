SELECT N'800' AS TransactionNumber, EinzTeil.Code AS ExternalIdentifier, Contain.Barcode AS BundleID, Kunden.KdNr AS CustomerID
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Contain ON Scans.ContainID = Contain.ID
JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE AnfKo.AuftragsNr = N'29820705';