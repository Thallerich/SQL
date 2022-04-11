WITH Eingangsscan AS (
  SELECT Scans.EinzTeilID, MAX(Scans.[DateTime]) AS LastScanIn
  FROM Scans
  WHERE Scans.ActionsID = 100
    AND Scans.Menge = 1
  GROUP BY Scans.EinzTeilID
)
SELECT KdGf.KurzBez AS SGF, EinzTeil.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, EinzTeil.ErstWoche, Eingangsscan.LastScanIn AS [letzter Eingangsscan], EinzTeil.WegDatum, WegGrund.WegGrundBez$LAN$ AS WegGrund, EinzTeil.AnzWasch AS [Anzahl Wäschen], Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung]
FROM EinzTeil
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
LEFT JOIN Eingangsscan ON Eingangsscan.EinzTeilID = EinzTeil.ID
WHERE Kunden.KdGfID IN ($2$)
  AND Kunden.StandortID IN ($1$)
  AND Artikel.EAN IS NOT NULL --nur UHF-Artikel
  AND EinzTeil.WegGrundID IN ($3$)
  AND EinzTeil.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Artikel.ArtikelBez, EinzTeil.WegDatum ASC;