SELECT DISTINCT
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [Vsa-Nr.],
  Vsa.SuchCode AS [Vsa-Stichwort],
  Vsa.Bez AS [Vsa-Bezeichnung],
  StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration],
  Touren.Tour,
  Touren.Bez AS [Tour-Bezeichnung],
  Wochentag = (SELECT WochTag.WochTagBez$LAN$ FROM WochTag WHERE WochTag.ID = Touren.Wochentag),
  Touren.StellplatzExpedi AS [Stellplatz Expedition]
FROM VsaTour
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  AND VsaBer.[Status] = N'A'
  AND KdBer.[Status] = N'A'
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND StandKon.ID IN ($1$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);