SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Expedition.SuchCode AS Expedition
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Standort AS Expedition ON Touren.ExpeditionID = Expedition.ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND (Expedition.SuchCode LIKE N'UKL_' OR Expedition.SuchCode = N'GRAZ')
  AND Bereich.Bereich = N'FW';