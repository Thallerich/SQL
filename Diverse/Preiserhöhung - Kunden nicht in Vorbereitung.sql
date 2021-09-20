SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode AS Kunde, ABC.ABCBez AS [ABC-Klasse], [Zone].ZonenCode AS Vertriebszone, KdGf.KurzBez AS [Geschäftsbereich], PrLauf.PrLaufBez AS Preiserhöhungslauf, CAST(IIF(Kunden.PrListKundenID > 0, 1, 0) AS bit) AS [über Preisliste?]
FROM Kunden
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Vertrag ON Vertrag.KundenID = Kunden.ID
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
WHERE Kunden.FirmaID = 5260
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ID NOT IN (
    SELECT Vertrag.KundenID
    FROM Vertrag
    JOIN PePo ON PePo.VertragID = Vertrag.ID
    JOIN PeKo ON PePo.PeKoID = PeKo.ID
    WHERE PeKo.Status = N'C'
  )
  AND EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.Status = N'A'
      AND Vertrag.KundenID = Kunden.ID
  )
  AND EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KundenID = Kunden.ID
      AND (KdArti.WaschPreis != 0 OR KdArti.LeasPreis != 0 OR KdArti.SonderPreis != 0 OR KdArti.VkPreis != 0)
  );