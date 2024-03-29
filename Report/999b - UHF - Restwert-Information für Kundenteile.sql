-- ##################################################################################################
-- Pipeline Kundendaten:
SELECT Kunden.KdNr, Kunden.SuchCode, MwSt.MwStBez$LAN$ AS MwStBez, MwSt.MwStSatz, MwSt.MwStFaktor
FROM Kunden, MwSt
WHERE Kunden.MwStID = MwSt.ID
  AND Kunden.ID = $ID$;

-- ##################################################################################################
-- Pipeline Schwund:
DECLARE @RwConfigID integer = (SELECT RwPoolTeileConfigID FROM Kunden WHERE ID = $ID$);
DECLARE @Awoche nchar(7) = (SELECT CAST(DATEPART(year, GETDATE()) AS nchar(4)) + N'/' + IIF(DATEPART(week, GETDATE()) < 10, N'0' + CAST(DATEPART(week, GETDATE()) AS nchar(1)), CAST(DATEPART(week, GETDATE()) AS nchar(2))) AS Woche);
DECLARE @RwArt integer = 1;
DECLARE @von datetime = $1$;
DECLARE @bis datetime = DATEADD(day, 1, $2$);

IF @RwConfigID < 0 BEGIN
  RAISERROR(N'Keine Pool-Restwertkonfiguration beim Kunden hinterlegt!', 16, 1);
END ELSE BEGIN
  SELECT Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Abteil.Abteilung AS KsStNr, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(OPTeile.ID) AS Menge, RWAkt.RestwertInfo AS EPreis, COUNT(OPTeile.ID) * RWAkt.RestwertInfo AS GPreis, @@ERROR AS Fehler
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Abteil ON Vsa.AbteilID = Abteil.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  CROSS APPLY funcGetRestwertOP(OPTeile.ID, @Awoche, @RwArt) AS RWAkt
  WHERE Kunden.ID = $ID$
    AND Bereich.Bereich <> N'EW'
    AND (OPTeile.Status = N'W' OR (OPTeile.Status IN (N'A', N'Q') AND OPTeile.LastActionsID = 102)) -- Schwundteile oder Teile aktuell beim Kunden
    AND OPTeile.RechPoID = -1
    AND OPTeile.LastScanToKunde BETWEEN @von AND @bis
  GROUP BY Vsa.SuchCode, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, RWAkt.RestwertInfo
  ORDER BY KsStNr, Artikel.ArtikelNr, EPreis;
END;