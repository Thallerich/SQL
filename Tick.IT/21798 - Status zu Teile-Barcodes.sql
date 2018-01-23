USE Wozabal
GO

SELECT __BCTXS.Barcode, IIF(T.StatusT IS NOT NULL, T.StatusT, T.StatusL) AS Status
FROM __BCTXS, (
  SELECT BCMPZ.Barcode, Teile.Status, Status.StatusBez AS StatusT, LStatus.StatusBez AS StatusL
  FROM __BCTXS AS BCMPZ
  LEFT OUTER JOIN Teile ON BCMPZ.Barcode COLLATE Latin1_General_CS_AS = Teile.Barcode
  LEFT OUTER JOIN Status ON Teile.Status = Status.Status AND Status.Tabelle = N'TEILE'
  LEFT OUTER JOIN TeileLag ON BCMPZ.Barcode COLLATE Latin1_General_CS_AS = TeileLag.Barcode
  LEFT OUTER JOIN Status AS LStatus ON TeileLag.Status = LStatus.Status AND LStatus.Tabelle = N'TEILELAG'
) T
WHERE T.Barcode = __BCTXS.Barcode
ORDER BY __BCTXS.Barcode

GO