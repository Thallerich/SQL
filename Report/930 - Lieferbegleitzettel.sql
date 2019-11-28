SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBez, Vsa.BarcodeNr AS VsaBarcode
FROM Fahrt
JOIN LsKo ON LsKo.FahrtID = Fahrt.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE LsPo.LsKoID = LsKo.ID
      AND Bereich.Bereich = N'FW'
  )
  AND Fahrt.ExpeditionID = $1$
  AND Fahrt.PlanDatum = $2$
  AND Fahrt.ID IN ($3$);