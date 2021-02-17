SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.Bereich AS Kundenbereich, Vertrag.Nr AS VertragNr, Vertrag.Bez AS VertragBezeichnung, Vertrag.Status
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KdBerID = KdBer.ID
      AND KdArti.Status != N'I'
      AND (KdArti.WaschPreis != 0 OR KdArti.LeasingPreis != 0 OR KdArti.SonderPreis != 0 OR KdArti.PeriodenPreis != 0)
  )
  AND Firma.SuchCode = N'FA14'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Vertrag.Status = N'I'
ORDER BY KdNr, Kundenbereich, VertragNr;