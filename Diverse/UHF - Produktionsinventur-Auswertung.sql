USE Wozabal
GO

CREATE TABLE #ProdInv (
  Chipcode nvarchar(100) COLLATE Latin1_General_CS_AS
)

BULK INSERT #ProdInv FROM N'D:\AdvanTex\Temp\Inventur.txt'
WITH (FIELDTERMINATOR = N'\r', ROWTERMINATOR = N'\n')

GO

SELECT 
  UPPER(ProdInv.Chipcode) AS Chipcode,
  ISNULL(Artikel.ArtikelNr, N'') AS ArtikelNr,
  ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung,
  ISNULL(Status.StatusBez, '') AS Teilestatus,
  [Letzte Aktion] = 
    CASE
      WHEN OPTeile.LastActionsID = 100 THEN N'Eingelesen (Teil ist in Produktion)'
      WHEN OPTeile.LastActionsID = 102 THEN N'Ausgelesen (Teil ist beim Kunden)'
      WHEN OPTeile.LastActionsID = 109 THEN N'Qualitätskontrolle (OP)'
      WHEN OPTeile.LastActionsID = 115 THEN N'Angelegt (Teil wurde noch nicht verwendet, nur codiert)'
      WHEN OPTeile.LastActionsID = 116 THEN N'Schwund'
      WHEN OPTeile.LastActionsID = 108 THEN N'Schrott'
      WHEN OPTeile.LastActionsID IS NULL THEN N''
      ELSE N'(unbekannt)'
    END,
  ISNULL(FORMAT(OPTeile.LastScanTime, 'G', 'de-AT'), '') AS [Letzter Scan],
  ISNULL(ZielNr.ZielNrBez, N'') AS [Letzter Scan-Ort],
  ISNULL(FORMAT(OPTeile.LastScanToKunde, 'G', 'de-AT'), '') AS [Letzter Ausgangs-Scan]
FROM (
  SELECT DISTINCT Chipcode FROM #ProdInv
) AS ProdInv
LEFT OUTER JOIN OPTeile ON UPPER(ProdInv.Chipcode) = OPTeile.Code
LEFT OUTER JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
LEFT OUTER JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
LEFT OUTER JOIN ZielNr ON OPTeile.ZielNrID = ZielNr.ID

GO

DROP TABLE IF EXISTS #ProdInv

GO