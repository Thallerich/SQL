SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS [Set-Bezeichnung], Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], OPEtiKo.Verfalldatum AS Verfallsdatum, COUNT(OPEtiKo.ID) AS [Anzahl Sets]
FROM OPEtiKo
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN Vsa ON OPEtiKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE OPEtiKo.[Status] = N'M'
  AND OPEtiKo.ProduktionID IN ($1$)
  AND OPEtiKo.AusleseZeitpunkt IS NULL
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, OPEtiKo.Verfalldatum
ORDER BY Verfallsdatum, Kundennummer, [VSA-Nummer] DESC;