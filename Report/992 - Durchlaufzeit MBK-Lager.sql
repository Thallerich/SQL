DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $2$);

WITH Ausgangsscan AS (
  SELECT MIN(Scans.ID) AS FirstOutScanID, Scans.EinzHistID
  FROM Scans
  WHERE Scans.Menge = -1
    AND Scans.EinzHistID > 0
  GROUP BY Scans.EinzHistID
)
SELECT KdGf.KurzBez AS SGF,
  EinzHist.Barcode,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  Auftrag.AuftragsNr,
  Auftrag.Zeitpunkt AS [Erstelldatum Auftrag],
  CAST(EinzHist.Anlage_ AS date) AS Anlage,
  Mitarbei.Name AS [Benutzer der Bestellung],
  EinzHist.Entnommen,
  EinzHist.PatchDatum,
  [Lager-Endkontrolle] = (
    SELECT TOP 1 Scans.[DateTime]
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.ActionsID = 49
    ORDER BY Scans.[DateTime] DESC
  ),
  Einlesescan = (
    SELECT TOP 1 Scans.[DateTime]
    FROM Scans
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.Menge = -1
    ORDER BY Scans.[DateTime] ASC
  ),
  EinzHist.IndienstDat AS Aktivierung,
  LsKo.LsNr,
  LsKo.Datum AS [erstes Lieferscheindatum],
  DATEDIFF(day, EinzHist.Anlage_, EinzHist.IndienstDat) AS Durchlaufzeit
FROM EinzHist
JOIN Auftrag ON EinzHist.StartAuftragID = Auftrag.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Mitarbei ON EinzHist.AnlageUserID_ = Mitarbei.ID
JOIN EntnPo ON EinzHist.EntnPoID = EntnPo.ID
JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
LEFT JOIN Ausgangsscan ON EinzHist.ID = Ausgangsscan.EinzHistID
LEFT JOIN Scans AS OutScan ON Ausgangsscan.FirstOutScanID = OutScan.ID
LEFT JOIN LsPo ON OutScan.LsPoID = LsPo.ID
LEFT JOIN LsKo ON LsPo.LsKoID = LsKo.ID
WHERE EinzHist.Status != '5' --keine stornierten Teile
  AND LagerArt.LagerID = $3$ --Lagerstandort
  AND EinzHist.Anlage_ BETWEEN @von AND @bis
  AND EinzHist.EinzHistTyp = 1
  AND CAST(EinzHist.Anlage_ AS date) <= EinzHist.PatchDatum;