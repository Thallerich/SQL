DECLARE @ProduktionID int = $1$;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], AnfArt.AnfArtBez AS [Anforderungsart VSA], N'Zählkunde' AS Bestellart, Touren.Tour, WochTag.WochtagBez$LAN$ AS Wochentag,
  Kundenbereiche = CAST(STUFF((
    SELECT N', ' + Bereich.Bereich
    FROM VsaTour AS vt
    JOIN KdBer ON vt.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE vt.VsaID = Vsa.ID
      AND vt.TourenID = Touren.ID
      AND (CAST(GETDATE() AS date) BETWEEN vt.VonDatum AND vt.BisDatum OR CAST(GETDATE() AS date) < vt.VonDatum)
    ORDER BY Bereich FOR XML PATH(N'')
  ), 1, 1, N'') AS nchar(100))
FROM Vsa
JOIN AnfArt ON Vsa.AnfArtID = AnfArt.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN WochTag ON Touren.Wochentag = WochTag.Wochentag
WHERE EXISTS (
    SELECT StandBer.*
    FROM StandBer
    WHERE StandBer.StandKonID = StandKon.ID
      AND StandBer.ProduktionID = @ProduktionID
  )
  AND (Vsa.ZRSchabK1ID > 0 OR Vsa.ZRSchabK2ID > 0)
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.[Status] = N'A'
  )
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND (CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum OR CAST(GETDATE() AS date) < VsaTour.VonDatum)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, AnfArt.AnfArtBez, Touren.Tour, WochTag.WochtagBez$LAN$, Vsa.ID, Touren.ID

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], AnfArt.AnfArtBez AS [Anforderungsart VSA], N'Bestellkunde' AS Bestellart, Touren.Tour, WochTag.WochtagBez$LAN$ AS Wochentag,
  Kundenbereiche = CAST(STUFF((
    SELECT N', ' + Bereich.Bereich
    FROM VsaTour AS vt
    JOIN KdBer ON vt.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE vt.VsaID = Vsa.ID
      AND vt.TourenID = Touren.ID
      AND (CAST(GETDATE() AS date) BETWEEN vt.VonDatum AND vt.BisDatum OR CAST(GETDATE() AS date) < vt.VonDatum)
    ORDER BY Bereich FOR XML PATH(N'')
  ), 1, 1, N'') AS nchar(100))
FROM Vsa
JOIN AnfArt ON Vsa.AnfArtID = AnfArt.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN WochTag ON Touren.Wochentag = WochTag.Wochentag
WHERE EXISTS (
    SELECT StandBer.*
    FROM StandBer
    WHERE StandBer.StandKonID = StandKon.ID
      AND StandBer.ProduktionID = @ProduktionID
  )
  AND Vsa.ZRSchabK1ID < 0
  AND Vsa.ZRSchabK2ID < 0
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.[Status] = N'A'
  )
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND (CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum OR CAST(GETDATE() AS date) < VsaTour.VonDatum)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, AnfArt.AnfArtBez, Touren.Tour, WochTag.WochtagBez$LAN$, Vsa.ID, Touren.ID