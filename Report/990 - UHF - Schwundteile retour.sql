/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-96116                                                                                                                  ++ */
/* ++ Author: Stefan THALLER - 2025-07-04                                                                                       ++ */
/* ++ Pipeline: prepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #SchwundRetour990;

CREATE TABLE #SchwundRetour990 (
  Holding nvarchar(10),
  KdNr int,
  Kunde nvarchar(20),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Chipcode varchar(33),
  RechNr bigint,
  Rechnungsdatum date,
  [Erstell-Datum Rechnungsposition] datetime2,
  [Erster Scan nach Verrechnung] datetime2,
  [Gutschrift bis X Tage nach Verrechnung] int,
  [wird gutgeschrieben] bit,
  [Zeitpunkt Schwundbuchung] datetime2,
  [Zeitpunkt Eingang nach Schwundbuchung] datetime2
);

INSERT INTO #SchwundRetour990 (Holding, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Chipcode, RechNr, Rechnungsdatum, [Erstell-Datum Rechnungsposition], [Erster Scan nach Verrechnung], [Gutschrift bis X Tage nach Verrechnung], [wird gutgeschrieben], [Zeitpunkt Schwundbuchung], [Zeitpunkt Eingang nach Schwundbuchung])
SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzTeil.Code AS Chipcode, RechKo.RechNr, RechKo.RechDat AS Rechnungsdatum, CAST(RechPo.Anlage_ AS date) AS [Erstell-Datum Rechnungsposition], EinzTeil.FirstScanAfterInvoice AS [Erster Scan nach Verrechnung], Kunden.RWGutschriftXTage AS [Gutschrift bis X Tage nach Verrechnung], CAST(IIF(Kunden.RWGutschriftXTage > 0 AND DATEADD(day, Kunden.RWGutschriftXTage, RechKo.RechDat) <= CAST(EinzTeil.FirstScanAfterInvoice AS date), 1, 0) AS bit) AS [wird gutgeschrieben], CAST(NULL AS datetime2) AS [Zeitpunkt Schwundbuchung], CAST(NULL AS datetime2) AS [Zeitpunkt Eingang nach Schwundbuchung]
FROM EinzTeil
JOIN RechPo ON EinzTeil.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE EinzTeil.[Status] < N'W'
  AND EinzTeil.RechPoID > 0
  AND EinzTeil.FirstScanAfterInvoice IS NOT NULL
  AND EinzTeil.FirstScanAfterInvoice > RechKo.RechDat
  AND RechPo.RPoTypeID = 23
  AND Kunden.ID IN ($3$);

IF ($1$ = 1)
BEGIN
  INSERT INTO #SchwundRetour990 (Holding, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Chipcode, RechNr, Rechnungsdatum, [Erstell-Datum Rechnungsposition], [Erster Scan nach Verrechnung], [Gutschrift bis X Tage nach Verrechnung], [wird gutgeschrieben], [Zeitpunkt Schwundbuchung], [Zeitpunkt Eingang nach Schwundbuchung])
  SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzTeil.Code AS Chipcode, NULL AS RechNr, NULL AS Rechnungsdatum, NULL AS [Erstell-Datum Rechnungsposition], NULL AS [Erster Scan nach Verrechnung], NULL AS [Gutschrift bis X Tage nach Verrechnung], NULL AS [wird gutgeschrieben], SchwundScan.[DateTime] AS [Zeitpunkt Schwundbuchung], EingangsScan.[DateTime] AS [Zeitpunkt Eingang nach Schwundbuchung]
  FROM (
    SELECT EinzTeil.ID AS EinzTeilID,
      SchwundScanID = (
        SELECT TOP 1 Scans.ID
        FROM Scans
        WHERE Scans.EinzTeilID = EinzTeil.ID
          AND Scans.ActionsID = 116
        ORDER BY Scans.[DateTime] DESC
      ),
      KundeVorSchwundScanID = (
        SELECT TOP 1 Scans.ID
        FROM Scans
        WHERE Scans.EinzTeilID = EinzTeil.ID
          AND Scans.Menge = -1
          AND Scans.ID < (
            SELECT TOP 1 Scans.ID
            FROM Scans
            WHERE Scans.EinzTeilID = EinzTeil.ID
              AND Scans.ActionsID = 116
            ORDER BY Scans.[DateTime] DESC
          )
        ORDER BY Scans.[DateTime] DESC
      ),
      EingangsScanID = (
        SELECT TOP 1 Scans.ID
        FROM Scans
        WHERE Scans.EinzTeilID = EinzTeil.ID
          AND Scans.Menge = 1
          AND Scans.ID > (
            SELECT TOP 1 Scans.ID
            FROM Scans
            WHERE Scans.EinzTeilID = EinzTeil.ID
              AND Scans.ActionsID = 116
            ORDER BY Scans.[DateTime] DESC
          )
        ORDER BY Scans.[DateTime] DESC
      )
    FROM EinzTeil
    WHERE EXISTS (
        SELECT Scans.*
        FROM Scans
        WHERE Scans.EinzTeilID = EinzTeil.ID
          AND Scans.ActionsID = 116
          AND EXISTS (
            SELECT Ausgangsscans.*
            FROM Scans AS Ausgangsscans
            WHERE Ausgangsscans.EinzTeilID = Scans.EinzTeilID
              AND Ausgangsscans.Menge = -1
              AND Ausgangsscans.ID < Scans.ID
              AND Ausgangsscans.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID IN ($3$))
          )
      )
  ) AS ScanInfo
  JOIN EinzTeil ON ScanInfo.EinzTeilID = EinzTeil.ID
  JOIN Scans AS Lieferscan ON ScanInfo.KundeVorSchwundScanID = Lieferscan.ID
  JOIN Scans AS SchwundScan ON ScanInfo.SchwundScanID = SchwundScan.ID
  JOIN Scans AS EingangsScan ON ScanInfo.EingangsScanID = EingangsScan.ID
  JOIN Vsa ON Lieferscan.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
  WHERE Lieferscan.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID IN ($3$));
END;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-96116                                                                                                                  ++ */
/* ++ Author: Stefan THALLER - 2025-07-04                                                                                       ++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT *
FROM #SchwundRetour990;