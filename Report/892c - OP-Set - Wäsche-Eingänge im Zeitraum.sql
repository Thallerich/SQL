DROP TABLE IF EXISTS #TmpOPEingang892c;

DECLARE @KundenID int = $ID$;
DECLARE @EingelesenVon datetime = CAST($1$ AS datetime);
DECLARE @EingelesenBis datetime = CAST(DATEADD(day, 1, $2$) AS datetime);

WITH InScan AS (
  SELECT Scans.EinzTeilID, Scans.[DateTime] AS Zeitpunkt, Scans.ZielNrID, Scans.EingAnfPoID
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN @EingelesenVon AND @EingelesenBis
    AND Scans.EingAnfPoID > 0
)
SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [Vsa-Stichwort],
  Vsa.Bez AS [Vsa-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  InScan.Zeitpunkt AS Einlesezeitpunkt,
  ZielNr.ZielNrBez AS [Einlese-Ort],
  LastOutScanID = (
    SELECT MAX(Scans.ID)
    FROM Scans
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Scans.[DateTime] < InScan.Zeitpunkt
      AND Scans.AnfPoID > 0
  ),
  LastPackScanID = (
    SELECT MAX(Scans.ID)
    FROM Scans
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Scans.[DateTime] < InScan.Zeitpunkt
      AND Scans.OPEtiKoID > 0
  ),
  EinzTeil.Code AS [Barcode Inhalts-Teil]
INTO #TmpOPEingang892c
FROM InScan
JOIN EinzTeil ON InScan.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN ZielNr ON InScan.ZielNrID = ZielNr.ID
JOIN AnfPo ON InScan.EingAnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = @KundenID;

SELECT InData.KdNr, InData.Kunde, InData.VsaNr, InData.[Vsa-Stichwort], InData.[Vsa-Bezeichnung], InData.[Barcode Inhalts-Teil], InData.ArtikelNr AS [Inhalts-ArtikelNr], InData.ArtikelBez AS [Inhalts-Bezeichnung], InData.Einlesezeitpunkt, InData.[Einlese-Ort], LsKo.LsNr AS [geliefert mit LsNr], LsKo.Datum AS [geliefert am], OPEtiKo.EtiNr AS [Set-Seriennummer], Artikel.ArtikelNr AS [Set-ArtikelNr], Artikel.ArtikelBeZ AS [Set-Bezeichnung]
FROM #TmpOPEingang892c AS InData
JOIN Scans AS OutScan ON InData.LastOutScanID = OutScan.ID
JOIN AnfPo ON OutScan.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN Scans AS PackScan ON InData.LastPackScanID = PackScan.ID
JOIN OPEtiKo ON PackScan.OPEtiKoID = OPEtiKo.ID
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID;