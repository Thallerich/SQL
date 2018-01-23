SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS Vsa, Vsa.Bez
FROM Kunden, Vsa, VsaTour, Touren, KdBer, VsaBer
WHERE Kunden.ID = Vsa.KundenID
	AND Vsa.ID = VsaTour.VsaID
	AND KdBer.BereichID = 106       -- OP-Textilien
	AND VsaBer.KdBerID = KdBer.ID
	AND VsaTour.KdBerID = KdBer.ID
	AND VsaTour.TourenID = Touren.ID
	AND Touren.ExpeditonID = 1      -- Lenzing IG
GROUP BY 1, 2, 3, 4
ORDER BY 1, 3;
