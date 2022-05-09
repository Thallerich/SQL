DROP TABLE IF EXISTS #teileneubuchen;

SELECT N'ZURUECKAUFERFASST;' + Teile.Barcode AS ModuleCallTeileAufErfasst, N'AUFTRAGCLOSE;' + RTRIM(CAST(Teile.StartAuftragID AS nvarchar)) AS ModuleCallAuftragClose, Teile.StartAuftragID
INTO #teileneubuchen
FROM Teile, EntnPo, EntnKo, Bestand, lagerart
WHERE Teile.EntnPoID = EntnPo.ID
  AND Teile.Status = N'K'
  AND EntnPo.EntnKoID = EntnKo.ID
  AND EntnKo.LagerID = 5167
  AND EntnPo.LagerArtID = Bestand.LagerArtID
  AND EntnPo.ArtGroeID = Bestand.ArtGroeID
  AND Bestand.Bestand = 0
  AND EntnPo.LagerArtID = Lagerart.ID
  AND Lagerart.SichtbarID > -1 /*ausklammern der _MZL Lager*/;

SELECT ModuleCallTeileAufErfasst FROM #teileneubuchen;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Output in AdvanTex als Modulaufruf - erst dann weitermachen!                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE Auftrag SET [Status] = N'F'
WHERE ID IN (
  SELECT DISTINCT StartAuftragID
  FROM #teileneubuchen
);

SELECT DISTINCT ModuleCallAuftragClose
FROM #teileneubuchen;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Output in AdvanTex als Modulaufruf                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */