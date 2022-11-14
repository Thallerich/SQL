DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $2$);

WITH Einlesescan AS (
  SELECT MIN(Scans.ID) AS FirstScanID, Scans.EinzHistID
  FROM Scans
  WHERE Scans.Menge = 1
    AND Scans.EinzHistID > 0
  GROUP BY Scans.EinzHistID
),
Ausgangsscan AS (
  SELECT MIN(Scans.ID) AS FirstOutScanID, Scans.EinzHistID
  FROM Scans
  WHERE Scans.Menge = -1
    AND Scans.EinzHistID > 0
  GROUP BY Scans.EinzHistID
)
SELECT KdGf.KurzBez AS SGF, EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Auftrag.AuftragsNr, Auftrag.Zeitpunkt AS [Erstelldatum Auftrag], CONVERT(date, EinzHist.Anlage_) AS Anlage, AnlageUser.Name AS [Benutzer der Bestellung], EntnKo._WorkOrderNumber AS [ABS-Pickliste], EinzHist.Entnommen, EinzHist.PatchDatum, Scans.[DateTime] AS Einlesescan, EinzHist.IndienstDat AS Aktivierung, LsKo.LsNr, LsKo.Datum AS [erstes Lieferscheindatum], DATEDIFF(day, EinzHist.Anlage_, EinzHist.IndienstDat) AS Durchlaufzeit
FROM EinzHist
LEFT JOIN Auftrag ON EinzHist.StartAuftragID = Auftrag.ID
LEFT JOIN Einlesescan ON EinzHist.ID = Einlesescan.EinzHistID
LEFT JOIN Scans ON Einlesescan.FirstScanID = Scans.ID
LEFT JOIN Ausgangsscan ON EinzHist.ID = Ausgangsscan.EinzHistID
LEFT JOIN Scans AS OutScan ON Ausgangsscan.FirstOutScanID = OutScan.ID
LEFT JOIN LsPo ON OutScan.LsPoID = LsPo.ID
LEFT JOIN LsKo ON LsPo.LsKoID = LsKo.ID, Vsa, Kunden, KdGf, Artikel, ArtGroe, LagerArt, Mitarbei AS AnlageUser, EntnPo, EntnKo
WHERE EinzHist.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND EinzHist.ArtikelID = Artikel.ID
  AND EinzHist.ArtGroeID = ArtGroe.ID
  AND EinzHist.LagerArtID = LagerArt.ID
  AND EinzHist.AnlageUserID_ = Anlageuser.ID
  AND EinzHist.EntnPoID = EntnPo.ID
  AND EntnPo.EntnKoID = EntnKo.ID
  AND EinzHist.Status <> '5' --keine stornierten Teile
  AND LagerArt.LagerID = $3$ --Lagerstandort
  AND EinzHist.Anlage_ BETWEEN @von AND @bis;