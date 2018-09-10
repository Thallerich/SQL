DROP TABLE IF EXISTS #KundenUmsatz;

CREATE TABLE #KundenUmsatz (
  Firma nvarchar(40),
  Kundenstatus nchar(12),
  KdNr int,
  Kunde nchar(20),
  [Kundenservice-Standort] nvarchar(40),
  Monat nchar(7),
  Umsatz money
);

DECLARE @Spalten nvarchar(max);
DECLARE @PivotSQL nvarchar(max);

INSERT INTO #KundenUmsatz
SELECT Firma.Bez AS Firma, [Status].StatusBez$LAN$ AS Kundenstatus, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS [Kundenservice-Standort], FORMAT(RechKo.RechDat, N'yyyy-MM') AS Monat, SUM(RechKo.BruttoWert) AS Umsatz
FROM Kunden
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN [Status] ON Kunden.[Status] = [Status].[Status] AND [Status].Tabelle = N'KUNDEN'
JOIN Firma ON Kunden.FirmaID = Firma.ID
LEFT OUTER JOIN RechKo ON RechKo.KundenID = Kunden.ID AND RechKo.FibuExpID > 0 AND RechKo.RechDat BETWEEN DATEADD(month, -12, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AND DATEADD(day, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
WHERE Kunden.FirmaID = $1$
GROUP BY Firma.Bez, [Status].StatusBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Standort.Bez, FORMAT(RechKo.RechDat, N'yyyy-MM');

SELECT @Spalten = COALESCE(@Spalten + ', [' + Monat + ']', '[' + Monat + ']') FROM (SELECT DISTINCT Monat FROM #KundenUmsatz WHERE Monat IS NOT NULL) AS K ORDER BY Monat ASC;

SET @PivotSQL = '
  SELECT *
  FROM (
    SELECT * FROM #KundenUmsatz
  ) AS x
  PIVOT (
    SUM(Umsatz)
    FOR Monat IN (' + @Spalten + ')
  ) AS p';

EXEC sp_executesql @PivotSQL;