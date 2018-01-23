DECLARE @Monatsanfang TIMESTAMP;
DECLARE @Monatsende TIMESTAMP;
DECLARE @Jahr Integer;
DECLARE @Monat Integer;

@Jahr = YEAR(CURDATE());
@Monat = MONTH(CURDATE());
@Monatsanfang = CREATETIMESTAMP(IIF(@Monat = 1, @Jahr - 1, @Jahr), IIF(@Monat = 1, 12, @Monat - 1), 1, 0, 0, 0, 0);
@Monatsende = CREATETIMESTAMP(@Jahr, @Monat, 1, 0, 0, 0, 0);

TRY
  DROP TABLE #TmpLagerbewegung;
CATCH ALL END;

SELECT LagerArt.LagerArtBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, IIF(LagerBew.BestandNeu = 0, LagerBew.EPreis, LagerBew.GleitPreis) AS EKPreis, CONVERT(NULL, SQL_DATE) AS EKseit, LagerBew.Differenz AS Buchungsmenge, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, LagerArt.ID AS LagerArtID, Bestand.ID AS BestandID, CONVERT(LagerBew.Zeitpunkt, SQL_DATE) AS Buchungsdatum, ArtGroe.Zuschlag
INTO #TmpLagerbewegung
FROM LagerBew, Bestand, ArtGroe, Artikel, LagerArt
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = 5001 --Umlauft
  AND LagerArt.Neuwertig = $TRUE$
  AND LagerBew.Zeitpunkt BETWEEN @Monatsanfang AND @Monatsende;

UPDATE Lagerbewegung SET EKSeit = ArtEKHis.GueltigSeit
FROM ArtEKHis, #TmpLagerbewegung AS Lagerbewegung
WHERE Lagerbewegung.ArtikelID = ArtEKHis.ArtikelID
  AND ArtEKHis.GueltigSeit <= Lagerbewegung.Buchungsdatum;

SELECT Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, EKPreis AS [EK-Preis], EKseit AS [EK-Preis vom], SUM(Buchungsmenge) AS Lagerbewegung, SUM(Buchungsmenge) * EKPreis AS [Wert Lagerbewegung]
FROM #TmpLagerbewegung
WHERE ArtikelID > 0
GROUP BY Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, EKPreis, EKseit;