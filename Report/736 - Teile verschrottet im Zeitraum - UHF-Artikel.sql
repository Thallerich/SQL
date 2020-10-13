WITH Eingangsscan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS LastScanIn
  FROM OPScans
  WHERE OPScans.ActionsID = 100
    AND OPScans.Menge = 1
  GROUP BY OPScans.OPTeileID
)
SELECT KdGf.KurzBez AS SGF, OpTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, OpTeile.ErstWoche, Eingangsscan.LastScanIn AS [letzter Eingangsscan], OpTeile.WegDatum, WegGrund.WegGrundBez$LAN$ AS WegGrund, OpTeile.AnzWasch AS [Anzahl Wäschen], Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung]
FROM OpTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN WegGrund ON OPTeile.WegGrundID = WegGrund.ID
LEFT JOIN Eingangsscan ON Eingangsscan.OPTeileID = OPTeile.ID
WHERE OpTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.KdGfID IN ($2$)
  AND Kunden.StandortID IN ($1$)
  AND OpTeile.ArtikelID = Artikel.ID
  AND Artikel.EAN IS NOT NULL --nur UHF-Artikel
  AND OpTeile.WegGrundID = WegGrund.ID
  AND OpTeile.WegGrundID IN ($3$)
  AND OpTeile.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Artikel.ArtikelBez, OpTeile.WegDatum ASC;