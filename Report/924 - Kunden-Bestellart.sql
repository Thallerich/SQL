DECLARE @ProduktionID int = $1$;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], N'Zählkunde' AS Bestellart
FROM Vsa
JOIN AnfArt ON Vsa.AnfArtID = AnfArt.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
WHERE EXISTS (
    SELECT StandBer.*
    FROM StandBer
    WHERE StandBer.StandKonID = StandKon.ID
      AND StandBer.ProduktionID = @ProduktionID
  )
  AND EXISTS (
    SELECT ZrSchabK.*
    FROM ZrSchabK
    WHERE ZrSchabK.VsaID = Vsa.ID
  )
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.[Status] = N'A'
  )
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], N'Bestellkunde' AS Bestellart
FROM Vsa
JOIN AnfArt ON Vsa.AnfArtID = AnfArt.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
WHERE EXISTS (
    SELECT StandBer.*
    FROM StandBer
    WHERE StandBer.StandKonID = StandKon.ID
      AND StandBer.ProduktionID = @ProduktionID
  )
  AND NOT EXISTS (
    SELECT ZrSchabK.*
    FROM ZrSchabK
    WHERE ZrSchabK.VsaID = Vsa.ID
  )
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.[Status] = N'A'
  )
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1;