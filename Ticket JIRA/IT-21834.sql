WITH ProduzentSchrottTeile AS (
  SELECT OPTeile.ID AS OPTeileID, OPTeile.ArtikelID, OPTeile.Code, OPTeile.WegDatum, OPTeile.WegGrundID
  FROM OPTeile
  WHERE OPTeile.[Status] = N'Z'
    AND OPTeile.LastScanTime BETWEEN N'2018-02-01 00:00:00' AND GETDATE()
    AND OPTeile.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.ProduktionsID = (SELECT ID FROM Standort WHERE Standort.SuchCode = N'BUDW')
        AND ZielNr.GeraeteNr IS NOT NULL
    )
),
AnzWaschStandort AS (
  SELECT OPTeile.ID AS OPTeileID, Standort.ID AS StandortID, COUNT(OPScans.ID) AS AnzWaschStandort
  FROM OPScans
  JOIN OPTeile ON OPScans.OpTeileID = OPTeile.ID
  JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN Vsa ON AnfKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  WHERE OPScans.AnfPoID > 0
  GROUP BY OPTeile.ID, Standort.ID
)
SELECT Code, ArtikelNr, Artikelbezeichnung, Schrottgrund, Schrottdatum, [WOEN] AS [Enns], [WOLE] AS Lenzing, [WOLI] AS Linz, [WOBH] AS [Bad Hofgastein], [UKLU] AS [Umlauft], [BUDW] AS [Budweis], [X] AS [Standort unbekannt]
FROM (
  SELECT ProduzentSchrottTeile.Code, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ProduzentSchrottTeile.WegDatum AS Schrottdatum, WegGrund.WeggrundBez AS Schrottgrund, IIF(Standort.SuchCode IN (N'WOLE', N'WOEN', N'WOLI', N'WOBH', N'BUDW', N'UKLU'), Standort.SuchCode, N'X') AS StandortKurz, AnzWaschStandort.AnzWaschStandort AS [Anzahl Wäschen Standort]
  FROM ProduzentSchrottTeile
  JOIN Artikel ON ProduzentSchrottTeile.ArtikelID = Artikel.ID
  JOIN AnzWaschStandort ON AnzWaschStandort.OPTeileID = ProduzentSchrottTeile.OPTeileID
  JOIN Standort ON AnzWaschStandort.StandortID = Standort.ID
  JOIN WegGrund ON ProduzentSchrottTeile.WegGrundID = WegGrund.ID
) AS FWDaten
PIVOT (
  SUM([Anzahl Wäschen Standort])
  FOR StandortKurz IN ([WOLE], [WOEN], [WOLI], [WOBH], [BUDW], [UKLU], [X])
) AS piv