DECLARE @AddCondition nchar(51) = N'OPTeile.ID IN (SELECT ID FROM #TmpSchwundTeile970a)';
DECLARE @RwConfigID integer = (SELECT RwPoolTeileConfigID FROM Kunden WHERE ID = $ID$);
DECLARE @RwArt integer = 1;
DECLARE @SetAusdRestwert bit = 1;

DROP TABLE IF EXISTS #TmpSchwundTeile970a;

SELECT OPTeile.ID
INTO #TmpSchwundTeile970a
FROM OPTeile, Vsa, Kunden, Artikel
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 90
  AND ((OPTeile.Status = 'Q' AND OPTeile.LastActionsID = 102) OR (OPTeile.Status = 'W' AND OPTeile.RechPoID = -1)) -- bei Schwund-Teilen nur nicht verrechnete und nicht für Verrechnung gesperrte Teile
  AND Artikel.EAN IS NOT NULL
  AND LENGTH(OPTeile.Code) = 24
  AND Artikel.BereichID <> 104;

EXEC procOPTeileCalculateRestWerte @AddCondition, @RwConfigID, @RwArt, @SetAusdRestwert;

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OPTeile.Code, OPTeile.Code2, OPTeile.LastScanToKunde AS [letzter Ausgangsscan], OPTeile.Erstwoche, IIF(OPTeile.WegDatum IS NOT NULL, OPTeile.AusdRestwert, OPTeile.RestwertInfo) AS Restwert
FROM OPTeile, Vsa, Kunden, Artikel
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 90
  AND ((OPTeile.Status = 'Q' AND OPTeile.LastActionsID = 102) OR (OPTeile.Status = 'W' AND OPTeile.RechPoID = -1)) -- bei Schwund-Teilen nur nicht verrechnete und nicht für Verrechnung gesperrte Teile
  AND Artikel.EAN IS NOT NULL
  AND LENGTH(OPTeile.Code) = 24
  AND Artikel.BereichID <> 104
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikel.ArtikelNr;