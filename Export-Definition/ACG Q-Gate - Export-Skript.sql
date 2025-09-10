DROP TABLE IF EXISTS #SpeisingBundle;

SELECT
  ExportLine =
    '800' + /* Trasnaction Number */
    LEFT(EinzHist.RentomatChip + REPLICATE(' ', 24), 24) +  /* External Identifier */
    LEFT(ISNULL(IIF(Scans.ContainID > 0, Contain.Barcode, (SELECT TOP 1 Contain.Barcode FROM LsCont JOIN Contain ON LsCont.ContainID = Contain.ID WHERE LsCont.LsKoID = LsKo.ID ORDER BY LsCont.ID DESC)), '') + REPLICATE(' ', 24), 24) + /* Bundle ID */
    LEFT(CAST(Kunden.KdNr AS nvarchar) + REPLICATE(' ', 8), 8) /* Customer ID */
INTO #SpeisingBundle
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Contain ON Scans.ContainID = Contain.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 20156
  AND Vsa.RentomatID = 108
  AND LsKo.Datum = CAST(DATEADD(day, 1, GETDATE()) AS date)
  AND LsKo.[Status] >= 'O'
  AND LsKo.LsKoArtID != (SELECT ID FROM LsKoArt WHERE Art = 'G');

SELECT TOP 1 '000  ' + LEFT('s20156_' + FORMAT(GETDATE(), 'yyyyMMdd') + '.dat' + REPLICATE(' ', 40), 40) + FORMAT(GETDATE(), 'ddMMyyyyHHmmss') AS ExportLine
FROM #SpeisingBundle

UNION ALL

SELECT ExportLine FROM #SpeisingBundle

UNION ALL

SELECT TOP 1 '999' AS ExportLine
FROM #SpeisingBundle;