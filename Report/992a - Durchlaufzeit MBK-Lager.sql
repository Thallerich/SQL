DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $2$);

WITH Einlesescan AS (
  SELECT MIN(Scans.ID) AS FirstScanID, Scans.TeileID
  FROM Scans
  WHERE Scans.Menge = 1
  GROUP BY Scans.TeileID
),
Ausgangsscan AS (
  SELECT MIN(Scans.ID) AS FirstOutScanID, Scans.TeileID
  FROM Scans
  WHERE Scans.Menge = -1
  GROUP BY Scans.TeileID
)
SELECT KdGf.KurzBez AS SGF, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Auftrag.AuftragsNr, Auftrag.Zeitpunkt AS [Erstelldatum Auftrag], CONVERT(date, Teile.Anlage_) AS Anlage, AnlageUser.Name AS [Benutzer der Bestellung], EntnKo._WorkOrderNumber AS [ABS-Pickliste], Teile.Entnommen, Teile.PatchDatum, Scans.[DateTime] AS Einlesescan, Teile.IndienstDat AS Aktivierung, LsKo.LsNr, LsKo.Datum AS [erstes Lieferscheindatum], DATEDIFF(day, Teile.Anlage_, Teile.IndienstDat) AS Durchlaufzeit
FROM Teile
LEFT JOIN Auftrag ON Teile.StartAuftragID = Auftrag.ID
LEFT JOIN Einlesescan ON Teile.ID = Einlesescan.TeileID
LEFT JOIN Scans ON Einlesescan.FirstScanID = Scans.ID
LEFT JOIN Ausgangsscan ON Teile.ID = Ausgangsscan.TeileID
LEFT JOIN Scans AS OutScan ON Ausgangsscan.FirstOutScanID = OutScan.ID
LEFT JOIN LsPo ON OutScan.LsPoID = LsPo.ID
LEFT JOIN LsKo ON LsPo.LsKoID = LsKo.ID, Vsa, Kunden, KdGf, Artikel, ArtGroe, LagerArt, Mitarbei AS AnlageUser, EntnPo, EntnKo
WHERE Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.LagerArtID = LagerArt.ID
  AND Teile.AnlageUserID_ = Anlageuser.ID
  AND Teile.EntnPoID = EntnPo.ID
  AND EntnPo.EntnKoID = EntnKo.ID
  AND Teile.Status <> '5' --keine stornierten Teile
  AND LagerArt.LagerID = $3$ --Lagerstandort
  AND Teile.Anlage_ BETWEEN @von AND @bis;