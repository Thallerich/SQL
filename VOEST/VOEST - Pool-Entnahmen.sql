DROP TABLE IF EXISTS #ScanHistory;
GO

SELECT Scans.EinzHistID, Scans.[DateTime] AS Ausgang, Scans.TraegerID, Scans.LsPoID, NextScanID = (
  SELECT MIN(s.ID)
  FROM Scans s
  WHERE s.EinzHistID = Scans.EinzHistID
    AND s.ID > Scans.ID
    AND (s.Menge = 1 OR s.ActionsID = 159)
)
INTO #ScanHistory
FROM Scans
JOIN Traeger ON Scans.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 272295
  AND Vsa.VsaNr IN (902, 903)
  AND Scans.ActionsID = 2
  AND Scans.ZielNrID = 2
  AND Scans.[DateTime] < N'2024-04-01 00:00:00.000'
  AND Scans.LsPoID > 0
  AND Traeger.ParentTraegerID > 0;

GO

DROP TABLE IF EXISTS #LeasWeek;
GO

SELECT #ScanHistory.EinzHistID, #ScanHistory.TraegerID, #ScanHistory.Ausgang, #ScanHistory.LsPoID, ISNULL(Scans.[DateTime], N'2024-04-01 00:00:00.000') AS Eingang, DATEDIFF(week, #ScanHistory.Ausgang, ISNULL(Scans.[DateTime], N'2024-04-01 00:00:00.000')) AS AnzWeek
INTO #LeasWeek
FROM #ScanHistory
LEFT JOIN Scans ON #ScanHistory.NextScanID = Scans.ID;

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], VaterVsa.GebaeudeBez AS Abteilung, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger, Traeger.PersNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, KdArti.Variante, EinzHist.Barcode, LeasStart.Woche AS [von KW], LeasEnd.Woche AS [bis KW], LeasWeek.AnzWeek AS [Anzahl Leasing-Wochen], CAST(LeasPreis.LeasPreisProWo AS float) AS [Leasingpreis wöchentlich], ROUND(LeasWeek.AnzWeek * CAST(LeasPreis.LeasPreisProWo AS float), 2) AS [Leasingbetrag]
FROM #LeasWeek LeasWeek
JOIN Traeger ON LeasWeek.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traeger AS VaterTraeger ON Traeger.ParentTraegerID = VaterTraeger.ID
JOIN Vsa AS VaterVsa ON VaterTraeger.VsaID = VaterVsa.ID
JOIN EinzHist ON LeasWeek.EinzHistID = EinzHist.ID
JOIN LsPo ON LeasWeek.LsPoID = LsPo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN [Week] AS LeasStart ON LeasWeek.Ausgang BETWEEN LeasStart.VonDat AND LeasStart.BisDat
JOIN [Week] AS LeasEnd ON LeasWeek.Eingang BETWEEN LeasEnd.VonDat AND LeasEnd.BisDat
CROSS APPLY advFunc_GetLeasPreisProWo(KdArti.ID) AS LeasPreis

GO