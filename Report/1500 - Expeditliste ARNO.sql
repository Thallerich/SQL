SELECT DISTINCT Touren.Tour, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS VsaBez
FROM AnfKo
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON AnfKo.TourenID = Touren.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
WHERE StandBer.ExpeditionID = $1$
  AND AnfKo.Lieferdatum = $2$
  AND AnfKo.LsKoID < 0            -- VSAs, für die der Packzettel bereits abgeschlossen wurde, ausblenden
ORDER BY Touren.Tour, Kunden.KdNr, VsaBez;