SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, ZrSchabK.Bez AS [Schablonen-Bezeichnung], ZrSchabP.SchachtNr, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ZrSchabK ON Vsa.ZRSchabK1ID = ZrSchabK.ID
JOIN ZrSchabP ON ZrSchabP.ZRSchabKID = ZrSchabK.ID
JOIN Artikel ON ZrSchabP.ArtikelID = Artikel.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
JOIN Standort aS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE Vsa.ZRSchabK1ID > 0
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Produktion.ID IN ($1$)
ORDER BY KdNr, VsaNr, SchachtNr;