SELECT Standort.Bez AS Haupstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], WegGrund.WeggrundBez$LAN$ AS [Lieferpausen-Grund], VsaPause.VonDatum AS [Lieferpause von], VsaPause.BisDatum AS [Lieferpause bis]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN VsaPause ON VsaPause.VsaID = Vsa.ID
JOIN WegGrund ON VsaPause.PauseGrundID = WegGrund.ID
WHERE VsaPause.KdArtiID < 0
  AND VsaPause.TraegerID < 0
  AND VsaPause.BisDatum >= CAST(GETDATE() AS date)
  AND VsaPause.IsLieferpause = 1
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Standort.ID IN ($1$)
  AND VsaPause.PauseGrundID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Haupstandort, KdNr, VsaNr;