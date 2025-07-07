SELECT CAST(FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') AS char(19)) AS Auswertungszeitpunkt,
   Ort,
  [Anzahl mit Rückmeldung] = SUM(IIF(Rückmeldung = 1, 1, 0)),
  [Anzahl ohne Rückmeldung] = SUM(IIF(Rückmeldung = 0, 1, 0))
FROM (
  SELECT SUBSTRING(SdcTcpL.Message60, 12, 4) AS Ort,
    [Rückmeldung] = CAST(IIF(EXISTS(
      SELECT 1
      FROM [SVATINZSQL1.sal.co.at].Salesianer_Inzing.dbo.SdcTcpL AS SdcTcpL2
      WHERE SdcTcpL2.TransNr = N'609'
        AND SdcTcpL2.Stamp BETWEEN SdcTcpL.Stamp AND DATEADD(minute, 1, SdcTcpL.Stamp)
        AND SdcTcpL2.Chipcode = SdcTcpL.Chipcode
    ), 1, 0) AS BIT)
  FROM [SVATINZSQL1.sal.co.at].Salesianer_Inzing.dbo.SdcTcpL
  WHERE SdcTcpL.TransNr = N'608'
    AND SdcTcpL.Stamp > DATEADD(minute, -60, GETDATE())
    AND NOT EXISTS (
      SELECT 1
      FROM [SVATINZSQL1.sal.co.at].Salesianer_Inzing.dbo.SdcTcpL AS SdcTcpL3
      WHERE SdcTcpL3.TransNr IN (N'608', N'609')
        AND SdcTcpL3.Chipcode = SdcTcpL.Chipcode
        AND SdcTcpL3.Stamp BETWEEN DATEADD(minute, -2, SdcTcpL.Stamp) AND SdcTcpL.Stamp
        AND SdcTcpL3.ID != SdcTcpL.ID
    )
) AS x
GROUP BY Ort
HAVING SUM(IIF(Rückmeldung = 0, 1, 0)) >= 10;