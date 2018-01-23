USE Wozabal
GO

SELECT
  Contain.Barcode AS Container,
  FORMAT(ContHist.Zeitpunkt, N'G', N'de-AT') AS [Anliefer-Zeitpunkt],
  (
    SELECT FORMAT(MIN(CH.Zeitpunkt), N'G', N'de-AT')
    FROM ContHist CH
    WHERE CH.ContainID = ContHist.ContainID
      AND CH.Zeitpunkt > ContHist.Zeitpunkt
  ) AS [Abhol-Zeitpunkt],
  Vsa.SuchCode AS VsaNr,
  Vsa.Bez AS Vsa,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde
FROM ContHist
JOIN Contain ON ContHist.ContainID = Contain.ID
JOIN Vsa ON ContHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 24045
  AND ContHist.Zeitpunkt > N'2017-01-01 00:00:00'
  AND ContHist.Status = N'e'
ORDER BY Contain.Barcode, ContHist.Zeitpunkt ASC

GO