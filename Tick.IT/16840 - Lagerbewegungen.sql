DECLARE @Monatsanfang TIMESTAMP;
DECLARE @Monatsende TIMESTAMP;
DECLARE @Jahr Integer;
DECLARE @Monat Integer;

@Jahr = YEAR(CURDATE());
@Monat = MONTH(CURDATE());
@Monatsanfang = CREATETIMESTAMP(IIF(@Monat = 1, @Jahr - 1, @Jahr), IIF(@Monat = 1, 12, @Monat - 1), 1, 0, 0, 0, 0);
@Monatsende = CREATETIMESTAMP(@Jahr, @Monat, 1, 0, 0, 0, 0);

TRY
  DROP TABLE #TmpLagerbestand;
CATCH ALL END;

SELECT LagerArt.LagerArtBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, ArtGroe.EKPreis, CONVERT(NULL, SQL_DATE) AS EKseit, 0 AS BestandMA, 0 AS BestandME, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, LagerArt.ID AS LagerArtID, Bestand.ID AS BestandID
INTO #TmpLagerbestand
FROM Bestand, ArtGroe, Artikel, LagerArt
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = 5001 --Umlauft
  AND LagerArt.Neuwertig = $TRUE$;

UPDATE Lagerbestand SET Lagerbestand.EKSeit = x.GueltigSeit
FROM #TmpLagerbestand AS Lagerbestand, (
  SELECT ArtEKHis.ArtikelID, MAX(ArtEKHis.GueltigSeit) AS GueltigSeit
  FROM ArtEKHis, Artikel
  WHERE ArtEKHis.ArtikelID = Artikel.ID
    AND ArtEKHis.LiefID = Artikel.LiefID
    AND ArtikelID IN (SELECT ArtikelID FROM #TmpLagerbestand)
  GROUP BY ArtEKHis.ArtikelID
) AS x
WHERE x.ArtikelID = Lagerbestand.ArtikelID;

UPDATE Lagerbestand SET Lagerbestand.BestandMA = (SELECT TOP 1 LagerBew.BestandNeu FROM LagerBew WHERE LagerBew.BestandID = Lagerbestand.BestandID AND LagerBew.Zeitpunkt < @Monatsanfang ORDER BY LagerBew.Zeitpunkt DESC)
FROM #TmpLagerbestand AS Lagerbestand;

UPDATE Lagerbestand SET Lagerbestand.BestandME = (SELECT TOP 1 LagerBew.BestandNeu FROM LagerBew WHERE LagerBew.BestandID = Lagerbestand.BestandID AND LagerBew.Zeitpunkt < @Monatsende ORDER BY LagerBew.Zeitpunkt DESC)
FROM #TmpLagerbestand AS Lagerbestand;

SELECT ArtikelNr, Artikelbezeichnung, Groesse, EKPreis, EKseit, SUM(IFNULL(BestandMA, 0)) AS BestandMA, SUM(IFNULL(BestandME, 0)) AS BestandME, (SUM(IFNULL(BestandME ,0)) - SUM(IFNULL(BestandMA, 0))) AS SumLagBew, (SUM(IFNULL(BestandME, 0)) - SUM(IFNULL(BestandMA, 0))) * EKPreis AS EurSumLagBew
FROM #TmpLagerbestand
WHERE ArtikelID > 0
GROUP BY ArtikelNr, Artikelbezeichnung, Groesse, EKPreis, EKseit;