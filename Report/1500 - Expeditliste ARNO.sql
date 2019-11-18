DECLARE @Wochentag int = (SELECT IIF(DATEPART(dw, $2$) > 1, DATEPART(dw, $2$) - 1, 7));

SELECT DISTINCT Touren.Tour, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS VsaBez
FROM VsaTour
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
WHERE StandBer.ExpeditionID = $1$
  AND Touren.Wochentag = @Wochentag
  AND EXISTS (
    SELECT AnfKo.*
    FROM AnfKo
    WHERE AnfKo.VsaID = Vsa.ID
      AND AnfKo.TourenID = Touren.ID
      AND AnfKo.Lieferdatum = $2$
      AND AnfKo.LsKoID < 0            -- VSAs, für die der Packzettel bereits abgeschlossen wurde, ausblenden
  )
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
  )
  
UNION ALL

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
  AND NOT EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    WHERE VsaTour.VsaID = Vsa.ID
      AND VsaTour.TourenID = Touren.ID
  )
ORDER BY Touren.Tour, Kunden.KdNr, VsaBez;
