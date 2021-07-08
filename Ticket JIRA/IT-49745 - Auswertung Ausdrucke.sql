SELECT Standort.SuchCode AS Standort, Formular = 
  CASE RptHisto.ReportFile
    WHEN N'Packzettel_Groessen' THEN N'Packzettel'
    WHEN N'Packzettel_CZ' THEN N'Packzettel'
    WHEN N'Lieferschein_SM' THEN N'Lieferschein'
    WHEN N'Lieferschein_CZ' THEN N'Lieferschien'
    WHEN N'BlankoPZ' THEN N'Blanko-Packzettel'
    WHEN N'LsCont' THEN N'Containerbeschriftungsblatt'
    WHEN N'DruckEtikett' THEN N'Ausliefer-Etikett'
    ELSE RptHisto.ReportFile
  END,
  FORMAT(RptHisto.GedrucktAm, N'yyyy-MM', N'de-AT') AS Monat, SUM(RptHisto.Anzahl) AS Anzahl, RIGHT(RptHisto.Druckername, LEN(RptHisto.Druckername) - ISNULL(CHARINDEX(N'\', RptHisto.Druckername, 3), 0)) AS Druckername
FROM RptHisto
JOIN Mitarbei ON RptHisto.MitarbeiID = Mitarbei.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE RptHisto.GedrucktAm >= N'2020-07-01'
  AND RptHisto.ReportFile IN (N'Packzettel', N'Packzettel_Groessen', N'Packzettel_CZ', N'Lieferschein', N'Lieferschein_SM', N'Lieferschein_CZ', N'LsCont', N'BlankoPZ', N'DruckEtikett')
  AND UPPER(ISNULL(RptHisto.Druckername, N'')) NOT IN (N'ZZZ_DUMMY', N'Default')
  AND RptHisto.Anzahl != 0
GROUP BY Standort.SuchCode,
  CASE RptHisto.ReportFile
    WHEN N'Packzettel_Groessen' THEN N'Packzettel'
    WHEN N'Packzettel_CZ' THEN N'Packzettel'
    WHEN N'Lieferschein_SM' THEN N'Lieferschein'
    WHEN N'Lieferschein_CZ' THEN N'Lieferschien'
    WHEN N'BlankoPZ' THEN N'Blanko-Packzettel'
    WHEN N'LsCont' THEN N'Containerbeschriftungsblatt'
    WHEN N'DruckEtikett' THEN N'Ausliefer-Etikett'
    ELSE RptHisto.ReportFile
  END,
  RptHisto.ReportTyp, FORMAT(RptHisto.GedrucktAm, N'yyyy-MM', N'de-AT'), RPTHISTO.Druckername
ORDER BY Formular, Monat, Standort;