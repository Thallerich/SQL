SELECT Kunden.KdNr, Kunden.SuchCode, Kunden.Name1, Kunden.Name2, VSa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS VsaBez, Vsa.BarcodeNr, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Touren.Tour, Touren.StellplatzExpedi, Touren.Wochentag, Sortier.Bez AS Sortierfolge, Vsa.SortierKunde
FROM Kunden, Vsa, VsaTour, Touren, Sortier
WHERE VsaTour.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaTour.TourenID = Touren.ID
  AND Vsa.SortierID = Sortier.ID
  AND Vsa.StandKonID IN ($2$)
  AND Touren.Wochentag = $1$
  AND Vsa.BarcodeNr IS NOT NULL
  AND Vsa.SortierKunde IS NOT NULL
  AND EXISTS (
    SELECT Traeger.ID
    FROM Traeger
    WHERE Traeger.VsaID = Vsa.ID
      AND Traeger.Altenheim = $FALSE$
  )
GROUP BY Kunden.KdNr, Kunden.SuchCode, Kunden.Name1, Kunden.Name2, Vsa.ID, Vsa.VsaNr, Vsa.Bez, Vsa.BarcodeNr, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Touren.Tour, Touren.StellplatzExpedi, Touren.Wochentag, Sortier.Bez, Vsa.SortierKunde
ORDER BY Kunden.KdNr, VsaID;