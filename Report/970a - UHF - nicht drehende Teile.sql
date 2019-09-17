DECLARE @RwArt integer = 1;
DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OPTeile.Code, OPTeile.Code2, OPTeile.LastScanToKunde AS [letzter Ausgangsscan], OPTeile.Erstwoche, OPRW.RestwertInfo AS Restwert
FROM OPTeile
CROSS APPLY funcGetRestwertOP(OPTeile.ID, @Woche, @RwArt) AS OPRW
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
WHERE Kunden.ID = $ID$
  AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 90
  AND ((OPTeile.Status = 'Q' AND OPTeile.LastActionsID = 102) OR (OPTeile.Status = 'W' AND OPTeile.RechPoID = -1)) -- bei Schwund-Teilen nur nicht verrechnete und nicht für Verrechnung gesperrte Teile
  AND Artikel.EAN IS NOT NULL
  AND LENGTH(OPTeile.Code) = 24
  AND Artikel.BereichID <> 104
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikel.ArtikelNr;