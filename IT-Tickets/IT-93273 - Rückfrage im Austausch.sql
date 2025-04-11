SELECT
  Firma = Firma.SuchCode,
  Vertriebszone = [Zone].ZonenCode,
  Hauptstandort = Standort.Bez,
  Kunden.KdNr,
  Kunde = Kunden.SuchCode,
  [hat BK-Teile] = 
    CASE
      WHEN EXISTS(SELECT EinzHist.* FROM EinzHist JOIN Vsa ON EinzHist.VsaID = Vsa.ID JOIN EinzTeil ON Einzhist.EinzTeilID = EinzTeil.ID WHERE Vsa.KundenID = Kunden.ID AND EinzHist.EinzHistTyp = 1 AND EinzHist.PoolFkt = 0 AND EinzTeil.AltenheimModus = 0 AND EinzHist.Status >= N'E' AND EinzHist.[Status] <= N'W') THEN CAST(1 AS bit)
      ELSE CAST(0 AS bit)
    END,
  [Rückfrage im Austausch] = 
    CASE Kunden.AustauschRueckfr
      WHEN N'A' THEN N'OK'
      WHEN N'B' THEN N'Rückfrage ab x Euro'
      WHEN N'C' THEN N'Nie zulassen'
      WHEN N'D' THEN N'Rückfrage, wenn Teil jünger als x Wochen'
      WHEN N'E' THEN N'Nie zulassen wenn Teil jünger als x Wochen'
      WHEN N'F' THEN N'Rückfrage, wenn Teil weniger als x Wäschen'
      WHEN N'G' THEN N'Rückfrage, wenn Teil jünger als x Wochen und weniger als x Wäschen'
      ELSE '??'
    END
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Firma.SuchCode = N'FA14'
  AND [Zone].ZonenCode IN (N'MITTE', N'WEST')
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A';