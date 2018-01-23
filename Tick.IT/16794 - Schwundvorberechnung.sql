DECLARE @AddCondition NVARCHAR(49);
DECLARE @RwConfigID Integer;
DECLARE @RwArt Integer;
DECLARE @SetAusdRestwert Logical;
DECLARE @von TIMESTAMP;
DECLARE @bis TIMESTAMP;

TRY
  DROP TABLE #TmpSchwundTeile;
CATCH ALL END;

-- Schwundteile ermitteln
SELECT OPTeile.ID
INTO #TmpSchwundTeile
FROM OPTeile, Vsa, Kunden, RwConfig, RwConfPo
WHERE OPTeile.Status = 'W'
  AND OPTeile.RechPoID < 0
  AND Kunden.RwPoolTeileConfigID = RwConfig.ID
  AND RwConfPo.RwConfigID = RwConfig.ID
  AND RwConfPo.RwArtID = 1
  AND OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND (RWConfig.RWFakIVSA = TRUE OR Vsa.Status = 'A')
  AND Kunden.ID = $ID$;

-- Parameter für Restwerte aktualisieren ermitteln
@AddCondition = 'OPTeile.ID IN (SELECT ID FROM #TmpSchwundTeile)';
@RwConfigID = (SELECT RwPoolTeileConfigID FROM Kunden WHERE ID = $ID$);
@RwArt = 1; -- Restwert-Art Fehlteile
@SetAusdRestwert = FALSE; --Ausdienst-Restwert nicht setzen, könnte sich bis zur tatsächlichen Berechnung noch ändern.

-- Restwerte aktualisieren
EXECUTE PROCEDURE procOPTeileCalculateRestWerte(@AddCondition, @RwConfigID, @RwArt, @SetAusdRestwert);

@von = CONVERT($1$ + ' 00:00:00', SQL_TIMESTAMP);
@bis = CONVERT($2$ + ' 23:59:59', SQL_TIMESTAMP);

SELECT Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Abteil.Abteilung AS KsStNr, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(OPTeile.ID) AS Menge, OPTeile.RestwertInfo AS EPreis, COUNT(OPTeile.ID) * OPTeile.RestwertInfo AS GPreis
FROM OPTeile, Vsa, Kunden, Artikel, Abteil
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Vsa.AbteilID = Abteil.ID
  AND Kunden.ID = $ID$
  AND OPTeile.Status = 'W'
  AND OPTeile.RechPoID < 0
  AND OPTeile.LastScanToKunde BETWEEN @von AND @bis
GROUP BY VsaStichwort, Vsa, KsStNr, Kostenstelle, Artikel.ArtikelNr, Artikelbezeichnung, EPreis
ORDER BY KsStNr, Artikel.ArtikelNr, EPreis;