/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Detail-Auswertung, für welche Container Miete fakturiert wurde, weil diese mehr als 28 Tage beim Kunden waren             ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2021-05-07                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @RechKoID int = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30099861);
DECLARE @KundenID int = (SELECT RechKo.KundenID FROM RechKo WHERE ID = @RechKoID);
DECLARE @LeasingVon date = (SELECT RechKo.VonDatum FROM RechKo WHERE ID = @RechKoID);
DECLARE @LeasingBis date = (SELECT RechKo.BisDatum From RechKo WHERE ID = @RechKoID);

DECLARE @pivotcols nvarchar(max);
DECLARE @pivotsql nvarchar(max);

DECLARE @KundenCont TABLE (
  ContainID int,
  KundenID int,
  VsaID int,
  Abladezeit datetime2 DEFAULT NULL,
  Abholzeit datetime2 DEFAULT NULL
);

DECLARE @FaktWeek TABLE (
  Woche nchar(7) COLLATE Latin1_General_CS_AS,
  VonDat date,
  BisDat date
);

DROP TABLE IF EXISTS #TmpContResult;

CREATE TABLE #TmpContResult (
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  Abladezeit datetime2,
  Abholzeit datetime2,
  Woche nchar(7) COLLATE Latin1_General_CS_AS
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Zum Kunden ausgelieferte Container ermitteln                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
INSERT INTO @KundenCont (ContainID, KundenID, VsaID, Abladezeit)
SELECT ContHist.ContainID, ContHist.KundenID, ContHist.VsaID, ContHist.Zeitpunkt AS Abladezeit
FROM ContHist
JOIN Kunden ON ContHist.KundenID = Kunden.ID
WHERE ContHist.Status = N'e'
  AND Kunden.ID = @KundenID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Hilfstabelle für Wochen-Berechnung erstellen                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
INSERT INTO @FaktWeek (Woche, VonDat, BisDat)
SELECT Week.Woche, Week.VonDat, Week.BisDat
FROM Week
WHERE Week.VonDat >= @LeasingVon
  AND Week.BisDat <= @LeasingBis;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Abholzeitpunkt der Container anhand nächstem Scan ermitteln                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
WITH ContRetour AS (
  SELECT ContHist.ContainID, KundenCont.Abladezeit, MIN(ContHist.Zeitpunkt) AS Abholzeit
  FROM ContHist
  JOIN @KundenCont AS KundenCont ON ContHist.ContainID = KundenCont.ContainID
  WHERE ContHist.Zeitpunkt > KundenCont.Abladezeit
  GROUP BY ContHist.ContainID, KundenCont.Abladezeit
)
UPDATE @KundenCont SET Abholzeit = ContRetour.Abholzeit
FROM @KundenCont AS KundenCont
JOIN ContRetour ON ContRetour.ContainID = KundenCont.ContainID AND ContRetour.Abladezeit = KundenCont.Abladezeit;

INSERT INTO #TmpContResult (Barcode, KdNr, Kunde, Abladezeit, Abholzeit, Woche)
SELECT Contain.Barcode, Kunden.KdNr, Kunden.SuchCode AS Kunde, KundenCont.Abladezeit, KundenCont.Abholzeit, FaktWeek.Woche
FROM @KundenCont AS KundenCont
JOIN Contain ON KundenCont.ContainID = Contain.ID
JOIN Kunden ON KundenCont.KundenID = Kunden.ID
LEFT JOIN @FaktWeek AS FaktWeek ON KundenCont.Abladezeit < DATEADD(day, -28, FaktWeek.BisDat) AND DATEADD(day, -28, ISNULL(KundenCont.Abholzeit, N'2099-12-31')) > FaktWeek.BisDat
WHERE DATEDIFF(day, KundenCont.Abladezeit, IIF(ISNULL(KundenCont.Abholzeit, GETDATE()) > @LeasingBis, @LeasingBis, KundenCont.Abholzeit)) >= 28
  AND ISNULL(KundenCont.Abholzeit, GETDATE()) > @LeasingVon;

SELECT DISTINCT Barcode, Abladezeit, Abholzeit FROM #TmpContResult;

SET @pivotcols = STUFF((SELECT DISTINCT ', [' + Woche + ']' FROM #TmpContResult FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotsql = N'SELECT Barcode, KdNr, Kunde, ' + @pivotcols + ' FROM (SELECT *, 1 AS Menge FROM #TmpContResult) AS Pivotdata PIVOT (SUM(Menge) FOR Woche IN (' + @pivotcols + ')) AS p;';

EXEC sp_executesql @pivotsql;

SELECT RechPo.*
FROM RechPo
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Artikel.ArtikelNr = N'CONTMIET'
  AND RechPo.RechKoID = @RechKoID;