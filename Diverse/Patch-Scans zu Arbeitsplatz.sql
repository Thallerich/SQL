SET NOCOUNT ON;
GO

USE Salesianer;
GO

DECLARE @workstationid int, @workstationname nvarchar(50), @from datetime, @to datetime, @sqltext nvarchar(max);

SET @workstationname = N'MATTPC046';
SET @from = CAST(N'2023-07-07 06:00:00' AS datetime);
SET @to = CAST(N'2023-07-07 06:50:00' AS datetime);

SET @sqltext = N'
SELECT @workstationid = ArbPlatz.ID
FROM ArbPlatz
WHERE ArbPlatz.ComputerName = @workstationname;
';

EXEC sp_executesql @sqltext, N'@workstationname nvarchar(50), @workstationid int OUTPUT', @workstationname, @workstationid = @workstationid OUTPUT;

SET @sqltext = N'
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger AS BewohnerNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, EinzHist.Barcode, Scans.[DateTime] AS [Patch-Druckzeitpunkt]
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
WHERE Scans.[DateTime] BETWEEN @from AND @to
  AND Scans.ArbPlatzID = @workstationid
  AND Scans.ActionsID = 23 /* Aktion: Patchen */
;';

EXEC sp_executesql @sqltext, N'@from datetime, @to datetime, @workstationid int', @from, @to, @workstationid;

GO