SELECT Kunden.KdNr, Kunden.SuchCode, Kunden.Name1, Kunden.Name2, VSa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS VsaBez, Vsa.BarcodeNr, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Sortier.SortierBez$LAN$ AS Sortierfolge, Vsa.SortierKunde
FROM Kunden, Vsa, Sortier
WHERE Vsa.KundenID = Kunden.ID
  AND Vsa.SortierID = Sortier.ID
  AND Vsa.StandKonID IN ($1$)
  AND Vsa.SortierKunde IS NOT NULL
  AND EXISTS (
    SELECT Traeger.ID
    FROM Traeger
    WHERE Traeger.VsaID = Vsa.ID
      AND Traeger.Altenheim = $FALSE$
  )
GROUP BY Kunden.KdNr, Kunden.SuchCode, Kunden.Name1, Kunden.Name2, Vsa.ID, Vsa.VsaNr, Vsa.Bez, Vsa.BarcodeNr, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Sortier.SortierBez$LAN$, Vsa.SortierKunde
ORDER BY Kunden.KdNr, VsaID;