SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez$LAN$ AS Kundenstatus, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS VSA, VsaStatus.StatusBez$LAN$ AS [VSA-Status], StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN [Status] AS Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status] AND Kundenstatus.Tabelle = N'KUNDEN'
JOIN [Status] AS VsaStatus ON Vsa.[Status] = VsaStatus.[Status] AND VsaStatus.Tabelle = N'VSA'
WHERE StandKon.ID IN ($1$)
  AND ((Kunden.Status = N'A' AND $2$ = 1) OR ($2$ = 0))
  AND ((Vsa.Status = N'A' AND $3$ = 1) OR ($3$ = 0))
  AND Kunden.AdrArtID = 1
ORDER BY Kunden.KdNr ASC, Vsa.VsaNr ASC;