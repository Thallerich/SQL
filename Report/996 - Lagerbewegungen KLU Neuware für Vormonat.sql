DECLARE @Monatsanfang DATE;
DECLARE @Monatsende DATE;
DECLARE @Jahr Integer;
DECLARE @Monat Integer;

set @Jahr = YEAR(GETDATE());
set @Monat = MONTH(GETDATE());
set @Monatsanfang = DATEFROMPARTS(IIF(@Monat = 1, @Jahr - 1, @Jahr), IIF(@Monat = 1, 12, @Monat - 1), 1);
set @Monatsende = DATEFROMPARTS(@Jahr, @Monat, 1);


DROP TABLE IF EXISTS #TmpLagerbewegung;

SELECT
  LagerArt.LagerArtBez$LAN$ AS Lagerart,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse,
  Lief.LiefNr AS [Lieferant-Nr],
  Lief.SuchCode AS Lieferant,
  CAST(0 AS money) AS Preis,
  CAST(0 AS money) AS PreisVormonat,
  CAST(0 AS bigint) AS MengeZugang,
  CAST(0 AS bigint) AS MengeAbgang,
  Artikel.ID AS ArtikelID,
  ArtGroe.ID AS ArtGroeID,
  LagerArt.ID AS LagerArtID,
  Bestand.ID AS BestandID,
  ArtGroe.Zuschlag,
  CAST(0 AS bigint) AS BestandMonatsbeginn,
  CAST(0 AS bigint) AS BestandMonatsende
INTO #TmpLagerbewegung
FROM Bestand, ArtGroe, Artikel, LagerArt, Lief
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND Artikel.LiefID = Lief.ID
  AND LagerArt.LagerID = $1$
  AND LagerArt.Neuwertig = 1;

UPDATE Lagerbewegung SET BestandMonatsbeginn = x.BestandBeginn, BestandMonatsende = x.BestandEnde, MengeZugang = x.MengeZugang, MengeAbgang = x.MengeAbgang
FROM #TmpLagerbewegung AS Lagerbewegung, (
  SELECT 
    Bestand.BestandID, 
    ISNULL((SELECT TOP 1 LB.BestandNeu FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt < @Monatsanfang ORDER BY LB.Zeitpunkt DESC, LB.ID DESC), 0) AS BestandBeginn,
    ISNULL((SELECT TOP 1 ISNULL(LB.BestandNeu, 0) FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt < @Monatsende ORDER BY LB.Zeitpunkt DESC, LB.ID DESC), 0) AS BestandEnde,
    ISNULL((SELECT SUM(CAST(LB.Differenz AS bigint)) FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt BETWEEN @Monatsanfang AND @Monatsende AND LB.Differenz > 0), 0) AS MengeZugang,
    ISNULL((SELECT SUM(CAST(LB.Differenz AS bigint)) FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt BETWEEN @Monatsanfang AND @Monatsende AND LB.Differenz < 0), 0) AS MengeAbgang
  FROM #TmpLagerbewegung AS Bestand
) AS x
WHERE x.BestandID = Lagerbewegung.BestandID;

UPDATE Lagerbewegung SET Preis = IIF(LagerBew.BestandNeu = 0, LagerBew.EPreis, LagerBew.GleitPreis)
FROM #TmpLagerbewegung AS Lagerbewegung, (
  SELECT LagerBew.BestandID, MAX(LagerBew.ID) AS ID
  FROM LagerBew
  WHERE LagerBew.BestandID IN (SELECT BestandID FROM #TmpLagerbewegung)
    AND LagerBew.EPreis <> 0
    AND LagerBew.GleitPreis <> 0
    AND LagerBew.Zeitpunkt BETWEEN @Monatsanfang AND @Monatsende
  GROUP BY LagerBew.BestandID
) AS MaxID, LagerBew
WHERE LagerBew.ID = MaxID.ID
  AND MaxID.BestandID = Lagerbewegung.BestandID;

UPDATE Lagerbewegung SET PreisVormonat = IIF(LagerBew.BestandNeu = 0, LagerBew.EPreis, LagerBew.GleitPreis)
FROM #TmpLagerbewegung AS Lagerbewegung, (
  SELECT LagerBew.BestandID, MAX(LagerBew.ID) AS ID
  FROM LagerBew
  WHERE LagerBew.BestandID IN (SELECT BestandID FROM #TmpLagerbewegung)
    AND LagerBew.EPreis <> 0
    AND LagerBew.GleitPreis <> 0
    AND LagerBew.Zeitpunkt < @Monatsanfang
  GROUP BY LagerBew.BestandID
) AS MaxID, LagerBew
WHERE LagerBew.ID = MaxID.ID
  AND MaxID.BestandID = Lagerbewegung.BestandID;

SELECT FORMAT(@Monatsanfang, 'd', 'de-at') + ' bis ' + FORMAT(DATEADD(day, -1, @Monatsende), 'd', 'de-at') AS Zeitraum, Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, [Lieferant-Nr], Lieferant, IIF(Preis = 0, PreisVormonat, Preis) AS Durchschnittspreis, PreisVormonat AS [Durschnittspreis Monatsbeginn], BestandMonatsbeginn, MengeZugang, MengeAbgang, BestandMonatsende , (MengeZugang + MengeAbgang) * Preis AS [Wert Lagerbewegung], BestandMonatsende * IIF(Preis = 0, PreisVormonat, Preis) AS [Wert Lagerbestand Monatsende]
FROM #TmpLagerbewegung
WHERE ArtikelID > 0
  AND (BestandMonatsbeginn > 0 OR BestandMonatsende > 0 OR MengeZugang > 0 OR MengeAbgang < 0)
ORDER BY ArtikelNr, Groesse;