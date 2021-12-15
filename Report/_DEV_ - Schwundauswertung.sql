DROP TABLE IF EXISTS #TmpResult;
GO

WITH Inventurscan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.ActionsID = 120
  GROUP BY OPScans.OPTeileID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS [VSA-Bezeichnung], OPTeile.Code AS Chipcode, Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez/* $LAN$ */ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], KdArti.Vertragsartikel, OPTeile.RestwertInfo, CAST(OPTeile.LastScanTime AS date) AS [letzter Scan], Actions.ActionsBez AS [letzte Aktion], CAST(Inventurscan.Zeitpunkt AS date) AS Inventurdatum, DATEDIFF(day, Inventurscan.Zeitpunkt, OPTeile.LastScanTime) AS [Tage zwischen Inventur und letztem Scan], OPTeile.Erstwoche AS [Erster Einsatz des Teils], OPTeile.ID AS OPTeileID
INTO #TmpResult
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
JOIN Inventurscan ON Inventurscan.OPTeileID = OPTeile.ID
WHERE OPTeile.Status = N'W'
  AND Kunden.KdNr = 10001933;

GO

DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

SELECT Result.KdNr, Result.Kunde, Result.[VSA-Bezeichnung], Result.Chipcode, Result.Produktbereich, Result.ArtikelNr, Result.Artikelbezeichnung, Result.Größe, Result.Vertragsartikel, RestwertAktuell.RestwertInfo, Result.RestwertInfo AS RWlautOPTeil, Result.[letzter Scan], Result.[letzte Aktion], Result.Inventurdatum, Result.[Tage zwischen Inventur und letztem Scan], Result.[Erster Einsatz des Teils]
FROM #TmpResult AS Result
CROSS APPLY funcGetRestwertOP(Result.OPTeileID, @curweek, 1) AS RestwertAktuell;

GO