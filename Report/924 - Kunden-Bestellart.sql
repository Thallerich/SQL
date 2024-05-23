SELECT KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], AnfArt.AnfArtBez AS [Anforderungsart VSA], IIF(Vsa.ZRSchabK1ID > 0 OR Vsa.ZRSchabK2ID > 0, N'Zählkunde', N'Bestellkunde') AS Bestellart, Touren.Tour, WochTag.WochtagBez$LAN$ AS Wochentag,
  Kundenbereiche = CAST(STUFF((
    SELECT N', ' + Bereich.Bereich
    FROM VsaTour AS vt
    JOIN KdBer ON vt.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE vt.VsaID = Vsa.ID
      AND vt.TourenID = Touren.ID
      AND (CAST(GETDATE() AS date) BETWEEN vt.VonDatum AND vt.BisDatum OR CAST(GETDATE() AS date) < vt.VonDatum)
      AND Bereich.ID IN ($3$)
      AND KdBer.[Status] = N'A'
    ORDER BY Bereich FOR XML PATH(N'')
  ), 1, 1, N'') AS nchar(100))
FROM Vsa
JOIN AnfArt ON Vsa.AnfArtID = AnfArt.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN WochTag ON Touren.Wochentag = WochTag.Wochentag
WHERE EXISTS (
    SELECT StandBer.*
    FROM StandBer
    WHERE StandBer.StandKonID = Vsa.StandKonID
      AND StandBer.ProduktionID IN ($2$)
      AND StandBer.BereichID IN ($3$)
  )
  AND (Vsa.ZRSchabK1ID > 0 OR Vsa.ZRSchabK2ID > 0)
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.[Status] = N'A'
  )
  AND EXISTS (
    SELECT VsaBer.*
    FROM VsaBer
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    WHERE VsaBer.VsaID = Vsa.ID
      AND KdBer.ID = VsaTour.KdBerID
      AND KdBer.BereichID IN ($3$)
      AND VsaBer.[Status] = N'A'
      AND KdBer.[Status] = N'A'
  )
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ZoneID IN ($1$)
  AND Vsa.AnfArtID IN ($4$)
  AND (CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum OR CAST(GETDATE() AS date) < VsaTour.VonDatum)
GROUP BY KdGf.KurzBez, [Zone].ZonenCode, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, AnfArt.AnfArtBez, IIF(Vsa.ZRSchabK1ID > 0 OR Vsa.ZRSchabK2ID > 0, N'Zählkunde', N'Bestellkunde'), Touren.Tour, WochTag.WochtagBez$LAN$, Vsa.ID, Touren.ID