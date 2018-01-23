USE Wozabal
GO

-- ################# Container-Auswertung #########################

SELECT Artikelbezeichnung AS Containertyp, [30] AS [Container < 30], [60] AS [Container < 60], [90] AS [Container < 90], [180] AS [Container < 180], [360] AS [Cointaner < 360], [9000] AS [Container > 360], [0] AS [kein Scan]
FROM (
  SELECT Artikelbezeichnung, ContainID, LastScanDays = 
    CASE
      WHEN DATEDIFF(day, LastScan, GETDATE()) <= 30 THEN 30
      WHEN DATEDIFF(day, LastScan, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, LastScan, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, LastScan, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, LastScan, GETDATE()) BETWEEN 181 AND 360 THEN 360
      WHEN LastScan IS NULL THEN 0
      ELSE 9000
    END
  FROM (
    SELECT Artikel.ArtikelBez AS Artikelbezeichnung, Contain.ID AS ContainID, MAX(ContHist.Zeitpunkt) AS LastScan
    FROM Contain
    JOIN Artikel ON Contain.ArtikelID = Artikel.ID
    LEFT OUTER JOIN ContHist ON ContHist.ContainID = Contain.ID
    WHERE Contain.ID > 0
    AND Artikel.ArtikelNr <> N'899000120000'
    GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Contain.ID
  ) x
) AS Container
PIVOT (
  COUNT(ContainID)
  FOR LastScanDays IN ([30], [60], [90], [180], [360], [9000], [0])
) AS ContainerPivot

GO

-- ################# Flachwäsche-Auswertung #######################

SELECT ArtikelNr, Artikelbezeichnung, [EK-Preis], Produktbereich, [30] AS [FW < 30], [60] AS [FW < 60], [90] AS [FW < 90], [180] AS [FW < 180], [360] AS [FW < 360], [9000] AS [FW > 360], [0] AS [FW ohne Scan]
FROM (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.EkPreis AS [EK-Preis], Bereich.BereichBez AS Produktbereich, LastScanDays = 
    CASE
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) <= 30 THEN 30
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 181 AND 360 THEN 360
      WHEN OPTeile.LastScanTime IS NULL THEN 0
      ELSE 9000
    END,
    COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  WHERE Bereich.Bereich IN (N'SH', N'TW', N'IK')
  AND OPTeile.Status < N'W'
  GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EKPreis, Bereich.BereichBez,
    CASE
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) <= 30 THEN 30
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) BETWEEN 181 AND 360 THEN 360
      WHEN OPTeile.LastScanTime IS NULL THEN 0
      ELSE 9000
    END
) AS Flachwaesche
PIVOT (
  SUM(Anzahl)
  FOR LastScanDays IN ([30], [60], [90], [180], [360], [9000], [0])
) AS FlachwaeschePivot

GO

-- ################# MBK-Umlauf-Auswertung ########################

SELECT ArtikelNr, Artikelbezeichnung, [EK-Preis], Produktbereich, Firma, [30] AS [BK < 30], [60] AS [BK < 60], [90] AS [BK < 90], [180] AS [BK < 180], [360] AS [BK < 360], [9000] AS [BK > 360], [0] AS [BK ohne Ausgang]
  FROM (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.EkPreis AS [EK-Preis], Bereich.BereichBez AS Produktbereich, Firma.Bez AS Firma, LastAusgang = 
    CASE
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) <= 30 THEN 30
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 181 AND 360 THEN 360
      WHEN Teile.Ausgang1 IS NULL THEN 0
      ELSE 9000
    END,
    COUNT(Teile.ID) AS Anzahl
  FROM Teile
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  WHERE Teile.Status BETWEEN N'L' AND N'W'
  AND Teile.Status <> N'T' --keine Verlustteile
  GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EkPreis, Bereich.BereichBez, Firma.Bez,
    CASE
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) <= 30 THEN 30
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 31 AND 60 THEN 60
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 61 AND 90 THEN 90
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 91 AND 180 THEN 180
      WHEN DATEDIFF(day, Teile.Ausgang1, GETDATE()) BETWEEN 181 AND 360 THEN 360
      WHEN Teile.Ausgang1 IS NULL THEN 0
      ELSE 9000
    END
) AS Bekleidung
PIVOT (
  SUM(Anzahl)
  FOR LastAusgang IN ([30], [60], [90], [180], [360], [9000], [0])
) AS BekleidungPivot

GO

-- ################# MBK-Lagerbestand-Auswertung ##################  

SELECT ArtikelNr, Artikelbezeichnung, [EK-Preis], Produktbereich, Art, [Lenzing GW] AS [Lenzing GW], [Lenzing IG] AS [Lenzing IG], [Rankweil] AS [Rankweil], [Budweis] AS [Budweis], [Umlauft] AS [Umlauft], [Gasser] AS [Gasser]
FROM (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.EKPreis AS [EK-Preis], Bereich.BereichBez AS Produktbereich, Standort.Bez AS Lagerstandort, IIF(LagerArt.Neuwertig = 1, 'Neuware', 'Gebraucht') AS Art, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  WHERE LagerArt.IstAnfLager = 0
  GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EkPreis, Bereich.BereichBez, Standort.Bez, LagerArt.Neuwertig
  HAVING SUM(Bestand.Bestand) > 0
) AS Lagerteile
PIVOT (
  SUM(Bestand)
  FOR Lagerstandort IN ([Lenzing GW], [Lenzing IG], [Rankweil], [Budweis], [Umlauft], [Gasser])
) AS LagerteilePivot

GO