-- ##################################################################################################
-- Pipeline Kundendaten:
SELECT Kunden.KdNr, Kunden.SuchCode, MwSt.Bez AS MwStBez, MwSt.MwStSatz, MwSt.MwStFaktor
FROM Kunden, MwSt
WHERE Kunden.MwStID = MwSt.ID
  AND Kunden.ID = $ID$;

-- ##################################################################################################
-- Pipeline Schwund:
DECLARE @AddCondition nvarchar(49) = N'OPTeile.ID IN (SELECT ID FROM #TmpSchwundTeile)';
DECLARE @RwConfigID integer = (SELECT RwPoolTeileConfigID FROM Kunden WHERE ID = $ID$);
DECLARE @RwArt integer = 1;
DECLARE @SetAusdRestwert bit = 0;
DECLARE @von datetime = $1$;
DECLARE @bis datetime = DATEADD(day, 1, $2$);

DROP TABLE IF EXISTS #TmpSchwundTeile;

IF @RwConfigID < 0 BEGIN
  RAISERROR(N'Keine Pool-Restwertkonfiguration beim Kunden hinterlegt!', 16, 1);
END ELSE BEGIN
  -- Schwundteile ermitteln
  SELECT OPTeile.ID
  INTO #TmpSchwundTeile
  FROM OPTeile, Vsa, Kunden, RwConfig, RwConfPo, Artikel, Bereich
  WHERE (OPTeile.Status = N'W' OR (OPTeile.Status IN (N'A', N'Q') AND OPTeile.LastActionsID = 102)) -- Schwundteile oder Teile aktuell beim Kunden
    AND OPTeile.RechPoID = -1
    AND Kunden.RwPoolTeileConfigID = RwConfig.ID
    AND RwConfPo.RwConfigID = RwConfig.ID
    AND OPTeile.ArtikelID = Artikel.ID
    AND Artikel.BereichID = Bereich.ID
    AND Bereich.Bereich <> N'EW'
    AND RwConfPo.RwArtID = 1
    AND OPTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND (RWConfig.RWFakIVSA = 1 OR Vsa.Status = 'A')
    AND Kunden.ID = $ID$;

  -- Restwerte aktualisieren
  EXECUTE procOPTeileCalculateRestWerte @AddCondition, @RwConfigID, @RwArt, @SetAusdRestwert;

  SELECT Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Abteil.Abteilung AS KsStNr, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(OPTeile.ID) AS Menge, OPTeile.RestwertInfo AS EPreis, COUNT(OPTeile.ID) * OPTeile.RestwertInfo AS GPreis, @@ERROR AS Fehler
  FROM OPTeile, Vsa, Kunden, Artikel, Abteil, Bereich
  WHERE OPTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND OPTeile.ArtikelID = Artikel.ID
    AND Artikel.BereichID = Bereich.ID
    AND Vsa.AbteilID = Abteil.ID
    AND Kunden.ID = $ID$
    AND Bereich.Bereich <> N'EW'
    AND (OPTeile.Status = N'W' OR (OPTeile.Status IN (N'A', N'Q') AND OPTeile.LastActionsID = 102)) -- Schwundteile oder Teile aktuell beim Kunden
    AND OPTeile.RechPoID = -1
    AND OPTeile.LastScanToKunde BETWEEN @von AND @bis
  GROUP BY Vsa.SuchCode, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, OPTeile.RestwertInfo
  ORDER BY KsStNr, Artikel.ArtikelNr, EPreis;
END;