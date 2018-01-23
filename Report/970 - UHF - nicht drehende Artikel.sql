SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(OPTeile.ID) AS AnzahlTeile
FROM OPTeile, Vsa, Kunden, Artikel
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 90
  AND ((OPTeile.Status = N'Q' AND OPTeile.LastActionsID = 102) OR (OPTeile.Status = 'W' AND OPTeile.RechPoID = -1)) -- bei Schwund-Teilen nur nicht verrechnete und nicht für Verrechnung gesperrte Teile
  AND Artikel.EAN IS NOT NULL
  AND LENGTH(OPTeile.Code) = 24
  AND Artikel.BereichID <> 104
GROUP BY Kunden.ID, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikelbezeichnung;