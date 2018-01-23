DECLARE @ZeitraumVon datetime;
DECLARE @ZeitraumBis datetime;

SET @ZeitraumVon = CONVERT(datetime, CAST('2016-01-01' AS date));
SET @ZeitraumBis = CONVERT(datetime, DATEADD(day, 1, CAST('2016-12-31' AS date)));

BEGIN TRY
  DROP TABLE #TmpLiefdauer000;
  DROP TABLE #TmpBestData000;
END TRY
BEGIN CATCH
END CATCH

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Lief.LiefNr, Lief.SuchCode AS Lieferant, 0 AS [Durchschnitt Tage bis AB], 0 AS [Durchschnitt Tage bis Lieferung], Artikel.ID AS ArtikelID, Lief.ID AS LiefID, ArtGroe.ID AS ArtGroeID
INTO #TmpLiefdauer000
FROM ArtGroe, Artikel, Lief
WHERE ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.LiefID = Lief.ID
  AND Lief.ID IN (83);

SELECT BKo.FreigabeZeitpkt, BPo.Menge AS Bestellmenge, LiefAbKo.Datum AS ABDatum, LiefLsKo.Datum AS Lieferdatum, LiefLsPo.Menge AS Liefermenge, BPo.ArtGroeID, BPo.ID AS BPoID, BKo.LiefID
INTO #TmpBestData000
FROM BKo, BPo
LEFT OUTER JOIN LiefAbPo ON LiefAbPo.BPoID = BPo.ID
LEFT OUTER JOIN LiefAbKo ON LiefAbKo.ID = LiefAbPo.LiefAbKoID
LEFT OUTER JOIN LiefLsPo ON LiefLsPo.BPoID = BPo.ID
LEFT OUTER JOIN LiefLsKo ON LiefLsKo.ID = LiefLsPo.LiefLsKoID
WHERE BPo.BKoID = BKo.ID
  AND BKo.LiefID IN (83)
  AND BKo.FreigabeZeitpkt BETWEEN @ZeitraumVon AND @ZeitraumBis;

UPDATE #TmpLiefdauer000
  SET [Durchschnitt Tage bis AB]  =
FROM (
  SELECT BestData000.BPoID, BestData000.ArtGroeID, BestData000.LiefID, MIN(BestData000.ABDatum) AS ABDatum, BestData000.FreigabeZeitpkt
  FROM #TmpBestData000
  GROUP BY BestData000.BPoID, BestData000.ArtGroeID, BestData000.LiefID
)