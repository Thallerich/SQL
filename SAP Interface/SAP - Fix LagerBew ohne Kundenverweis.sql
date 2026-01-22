DROP TABLE IF EXISTS #LagerBewFix;
GO

SELECT LagerBew.ID AS LagerBewID, EinzHist.KundenID, EinzHist.VsaID, EinzHist.TraeArtiID, EinzHist.EntnPoID
INTO #LagerBewFix
FROM LagerBew
JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
JOIN EinzHist ON LagerBew.Barcode = EinzHist.Barcode AND LagerBew.Zeitpunkt BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
WHERE LagerBew.ID IN (53681692, 53781833, 54457166, 56053370);

UPDATE LagerBew
  SET KundenID = IIF(LagerBew.KundenID = -1, #LagerBewFix.KundenID, LagerBew.KundenID),
      VsaID = IIF(LagerBew.VsaID = -1, #LagerBewFix.VsaID, LagerBew.VsaID),
      TraeArtiID = IIF(LagerBew.TraeArtiID = -1, #LagerBewFix.TraeArtiID, LagerBew.TraeArtiID),
      EntnPoID = IIF(LagerBew.EntnPoID = -1, #LagerBewFix.EntnPoID, LagerBew.EntnPoID)
FROM #LagerBewFix
WHERE LagerBew.ID = #LagerBewFix.LagerBewID;

GO

DROP TABLE IF EXISTS #LagerBewFix;
GO