SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Expedition.SuchCode AS Expedition, Touren.Tour, VsaTour.Folge, Vsa.LsUnterschr AS [Unterschrift notwendig]
FROM VsaTour
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Standort AS Expedition ON Touren.ExpeditionID = Expedition.ID
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND GETDATE() BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  AND VsaTour.Bringen = 1
  AND Expedition.ID IN ($1$)
  AND Touren.Wochentag = $2$
  AND (($3$ = 1 AND Vsa.LsUnterschr = 1) OR ($3$ = 0))
ORDER BY Tour, Folge;