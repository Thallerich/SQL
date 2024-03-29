DECLARE @Beginn DATE;
DECLARE @Ende DATE;

set @Beginn = $1$;
set @Ende = $2$;

DROP TABLE IF EXISTS #TmpLagerbewegung;

SELECT
  LagerArt.LagerArtBez$LAN$ AS Lagerart,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse,
  CAST(0 AS money) AS Preis,
  CAST(0 AS money) AS PreisVormonat,
  CAST(0 AS bigint) AS MengeZugang,
  CAST(0 AS bigint) AS MengeAbgang,
  Artikel.ID AS ArtikelID,
  ArtGroe.ID AS ArtGroeID,
  LagerArt.ID AS LagerArtID,
  Bestand.ID AS BestandID,
  ArtGroe.Zuschlag,
  CAST(0 AS bigint) AS BestandBeginn,
  CAST(0 AS bigint) AS BestandEnde
INTO #TmpLagerbewegung
FROM Bestand, ArtGroe, Artikel, LagerArt
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID IN ($3$)
  AND Artikel.BereichID IN ($4$)
  AND LagerArt.Neuwertig = 1
  AND Artikel.ArtiTypeID = 1;  -- nur textile Artikel, keine Namenschilder, Embleme, ...

UPDATE Lagerbewegung SET BestandBeginn = x.BestandBeginn, BestandEnde = x.BestandEnde, MengeZugang = x.MengeZugang, MengeAbgang = x.MengeAbgang
FROM #TmpLagerbewegung AS Lagerbewegung, (
  SELECT 
    Bestand.BestandID, 
    ISNULL((SELECT TOP 1 LB.BestandNeu FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt < @Beginn ORDER BY LB.Zeitpunkt DESC, LB.ID DESC), 0) AS BestandBeginn,
    ISNULL((SELECT TOP 1 ISNULL(LB.BestandNeu, 0) FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt < @Ende ORDER BY LB.Zeitpunkt DESC, LB.ID DESC), 0) AS BestandEnde,
    ISNULL((SELECT SUM(CAST(LB.Differenz AS bigint)) FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt BETWEEN @Beginn AND @Ende AND LB.Differenz > 0), 0) AS MengeZugang,
    ISNULL((SELECT SUM(CAST(LB.Differenz AS bigint)) FROM LagerBew LB WHERE LB.BestandID = Bestand.BestandID AND LB.Zeitpunkt BETWEEN @Beginn AND @Ende AND LB.Differenz < 0), 0) AS MengeAbgang
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
    AND LagerBew.Zeitpunkt BETWEEN @Beginn AND @Ende
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
    AND LagerBew.Zeitpunkt < @Beginn
  GROUP BY LagerBew.BestandID
) AS MaxID, LagerBew
WHERE LagerBew.ID = MaxID.ID
  AND MaxID.BestandID = Lagerbewegung.BestandID;

UPDATE Lagerbewegung SET Preis = ArtGroe.EKPreis, PreisVormonat = ArtGroe.EKPreis
FROM #TmpLagerbewegung AS Lagerbewegung, ArtGroe
WHERE Lagerbewegung.ArtGroeID = ArtGroe.ID
  AND Lagerbewegung.Preis = 0
  AND Lagerbewegung.PreisVormonat = 0;

SELECT FORMAT(@Beginn, 'd', 'de-at') + ' bis ' + FORMAT(DATEADD(day, -1, @Ende), 'd', 'de-at') AS Zeitraum, Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, IIF(Preis = 0, PreisVormonat, Preis) AS Durchschnittspreis, PreisVormonat AS [Durchschnittspreis Zeitraum-Beginn], BestandBeginn, MengeZugang, MengeAbgang, BestandEnde , (MengeZugang + MengeAbgang) * Preis AS [Wert Lagerbewegung], BestandEnde * IIF(Preis = 0, PreisVormonat, Preis) AS [Wert Lagerbestand Zeitraum-Ende]
FROM #TmpLagerbewegung
WHERE ArtikelID > 0
  AND (BestandBeginn > 0 OR BestandEnde > 0 OR MengeZugang > 0 OR MengeAbgang < 0)
ORDER BY ArtikelNr, Groesse;