DECLARE @Checkliste TABLE (
  Datum date,
  Startzeitpunkt datetime,
  Endzeitpunkt datetime,
  Laufzeit int,
  [Version] nchar(12)
);

DECLARE @SystemCheckliste TABLE (
  Datum date,
  Startzeitpunkt datetime,
  Endzeitpunkt datetime,
  Laufzeit int,
  [Version] nchar(12)
);

DECLARE @RefInt TABLE (
  Datum date,
  Startzeitpunkt datetime,
  Endzeitpunkt datetime,
  Laufzeit int,
  [Version] nchar(12)
);

INSERT INTO @Checkliste (Datum, Startzeitpunkt, Endzeitpunkt, Laufzeit, [Version])
SELECT CAST(LogItem.Anlage_ AS date) AS Datum,
  CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Startzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Startzeitpunkt: ') + 1, 19), 104) AS Startzeitpunkt,
  CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Endzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Endzeitpunkt: ') + 1, 19), 104) AS Endzeitpunkt,
  DATEDIFF(second, CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Startzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Startzeitpunkt: ') + 1, 19), 104), CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Endzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Endzeitpunkt: ') + 1, 19), 104)) AS Laufzeit,
  SUBSTRING(LogItem.[Version], CHARINDEX(N'(', LogItem.[Version], 1) + 1, CHARINDEX(N')', LogItem.[Version], 1) - CHARINDEX(N'(', LogItem.[Version], 1) - 1) AS [Version]
FROM LogItem
WHERE LogItem.Anlage_ > N'2024-12-01 00:00:00.000'
  AND LogItem.LogCaseID = (SELECT LogCase.ID FROM LogCase WHERE LogCase.Bez = N'TFormChecklisten.StartCheck[772]')
  AND LogItem.[Version] LIKE N'JOB %';
  
INSERT INTO @SystemCheckliste (Datum, Startzeitpunkt, Endzeitpunkt, Laufzeit, [Version])
SELECT CAST(LogItem.Anlage_ AS date) AS Datum,
  CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Startzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Startzeitpunkt: ') + 1, 19), 104) AS Startzeitpunkt,
  CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Endzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Endzeitpunkt: ') + 1, 19), 104) AS Endzeitpunkt,
  DATEDIFF(second, CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Startzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Startzeitpunkt: ') + 1, 19), 104), CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Endzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Endzeitpunkt: ') + 1, 19), 104)) AS Laufzeit,
  SUBSTRING(LogItem.[Version], CHARINDEX(N'(', LogItem.[Version], 1) + 1, CHARINDEX(N')', LogItem.[Version], 1) - CHARINDEX(N'(', LogItem.[Version], 1) - 1) AS [Version]
FROM LogItem
WHERE LogItem.Anlage_ > N'2024-12-01 00:00:00.000'
  AND LogItem.LogCaseID = (SELECT LogCase.ID FROM LogCase WHERE LogCase.Bez = N'TTabSQLCheck.RunAllExecute[151]')
  AND LogItem.[Version] LIKE N'JOB %';
  
INSERT INTO @RefInt (Datum, Startzeitpunkt, Endzeitpunkt, Laufzeit, [Version])
SELECT CAST(LogItem.Anlage_ AS date) AS Datum,
  CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Startzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Startzeitpunkt: ') + 1, 19), 104) AS Startzeitpunkt,
  CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Endzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Endzeitpunkt: ') + 1, 19), 104) AS Endzeitpunkt,
  DATEDIFF(second, CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Startzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Startzeitpunkt: ') + 1, 19), 104), CONVERT(datetime, SUBSTRING(LogItem.Memo, CHARINDEX(N'Endzeitpunkt: ', LogItem.Memo, 1) + LEN(N'Endzeitpunkt: ') + 1, 19), 104)) AS Laufzeit,
  SUBSTRING(LogItem.[Version], CHARINDEX(N'(', LogItem.[Version], 1) + 1, CHARINDEX(N')', LogItem.[Version], 1) - CHARINDEX(N'(', LogItem.[Version], 1) - 1) AS [Version]
FROM LogItem
WHERE LogItem.Anlage_ > N'2024-12-01 00:00:00.000'
  AND LogItem.LogCaseID = (SELECT LogCase.ID FROM LogCase WHERE LogCase.Bez = N'TFormRefIntCheck.BtnCheckAllClick[156]')
  AND LogItem.[Version] LIKE N'JOB %';

SELECT Checkliste.Datum,
  Checkliste.[Version],
  FORMAT(Checkliste.Startzeitpunkt, N'HH:mm:ss') AS [Start],
  FORMAT(RefInt.Endzeitpunkt, N'HH:mm:ss') AS Ende,
  CAST(Checkliste.Laufzeit / 60 / 60 AS varchar(10)) + ':' + RIGHT(N'00' + CAST(Checkliste.Laufzeit / 60 % 60 AS varchar(10)), 2) AS [Checklisten],
  CAST(SystemCheckliste.Laufzeit / 60 / 60 AS varchar(10)) + ':' + RIGHT(N'00' + CAST(SystemCheckliste.Laufzeit / 60 % 60 AS varchar(10)), 2) AS [System-Checklisten],
  CAST(RefInt.Laufzeit / 60 / 60 AS varchar(10)) + ':' + RIGHT(N'00' + CAST(RefInt.Laufzeit / 60 % 60 AS varchar(10)), 2) AS [Referentielle Integrität],
  CAST((Checkliste.Laufzeit + SystemCheckliste.Laufzeit + RefInt.Laufzeit) / 60 / 60 AS varchar(10)) + ':' + RIGHT(N'00' + CAST((Checkliste.Laufzeit + SystemCheckliste.Laufzeit + RefInt.Laufzeit) / 60 % 60 AS varchar(10)), 2) AS [Gesamt-Laufzeit]
FROM @Checkliste AS Checkliste
JOIN @SystemCheckliste AS SystemCheckliste ON Checkliste.Datum = SystemCheckliste.Datum
JOIN @RefInt AS RefInt ON Checkliste.Datum = RefInt.Datum
ORDER BY Datum DESC;