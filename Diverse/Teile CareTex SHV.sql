SELECT COUNT(Teile.ID) AS AnzahlTeile, Vsa.VsaNr, Vsa.Bez, Kunden.KdNr, Kunden.SuchCode, Kunden.Name1, Kunden.Name2, Kunden.Name3
FROM Kunden, Holding, Vsa, Traeger, Teile
WHERE Teile.TraegerID = Traeger.ID AND Traeger.VsaID = Vsa.ID AND Vsa.KundenID = Kunden.ID AND Kunden.HoldingID = Holding.ID AND Holding.Holding LIKE ('SHV%') AND Traeger.Status <> 'I'
GROUP BY 2, 3, 4, 5, 6, 7, 8
ORDER BY Kunden.KdNr