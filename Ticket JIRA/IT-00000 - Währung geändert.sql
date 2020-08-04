WITH Rech2 AS (
  SELECT MAX(RechKo.RechDat) AS MaxRechDat, RechKo.KundenID
  FROM RechKo
  WHERE RechKo.RechDat > N'2020-01-01'
    AND RechKo.RechWaeID = 64
    AND RechKo.Status < N'X'
  GROUP BY RechKo.KundenID
),
Rech3 AS (
  SELECT MAX(RechKo.RechDat) AS MaxRechDat, RechKo.KundenID
  FROM RechKo
  WHERE RechKo.RechDat > N'2020-01-01'
    AND RechKo.RechWaeID = 3
    AND RechKo.Status < N'X'
  GROUP BY RechKo.KundenID
),
Rech4 AS (
  SELECT MAX(RechKo.RechDat) AS MaxRechDat, RechKo.KundenID
  FROM RechKo
  WHERE RechKo.RechDat > N'2020-01-01'
    AND RechKo.RechWaeID = -1
    AND RechKo.Status < N'X'
  GROUP BY RechKo.KundenID
),
PE AS (
  SELECT DISTINCT KdArti.KundenID, PeKo.Bez AS Preiserhöhung, PeKo.DurchfuehrungsDatum, PeKo.WirksamDatum
  FROM PrArchiv
  JOIN KdArti ON PrArchiv.KdArtiID = KdArti.ID
  JOIN PeKo ON PrArchiv.PeKoID = PeKo.ID
  WHERE PeKo.DurchfuehrungsDatum >= N'2020-04-01'
    AND PeKo.Status = N'N'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, VertragWae.Code AS [Vertragswährung aktuell], RechWae.Code AS [Rechnungswährung aktuell], Rech2.[MaxRechDat] AS [Letzte Rechnung 2 NK], Rech3.MaxRechDat AS [Letzte Rechnung 3 NK], Rech4.MaxRechDat AS [Letzte Rechnung 4 NK], PE.Preiserhöhung, PE.WirksamDatum AS [wirksam ab], PE.DurchfuehrungsDatum AS [durchgeführt am]
FROM Kunden
JOIN Wae AS VertragWae ON Kunden.VertragWaeID = VertragWae.ID
JOIN Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
LEFT JOIN Rech2 ON Rech2.KundenID = Kunden.ID
LEFT JOIN Rech3 ON Rech3.KundenID = Kunden.ID
LEFT JOIN Rech4 ON Rech4.KundenID = Kunden.ID
LEFT JOIN PE ON PE.KundenID = Kunden.ID
WHERE EXISTS (
  SELECT RechKo.*
  FROM RechKo
  WHERE RechKo.KundenID = Kunden.ID
    AND RechKo.RechDat > N'2020-01-01'
    AND RechKo.RechWaeID != Kunden.RechWaeID
    AND RechKo.Status < N'X'
)
ORDER BY Kunden.KdNr ASC;