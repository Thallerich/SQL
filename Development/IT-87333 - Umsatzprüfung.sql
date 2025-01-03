DECLARE @curmonth nchar(7), @curmonthstart date, @curmonthend date, @prevmonth nchar(7), @prevmonthstart date, @prevmonthend date;
DECLARE @sql nvarchar(max);

SELECT @curmonth = FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), N'yyyy-MM'),
  @curmonthstart = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0),
  @curmonthend = EOMONTH(DATEADD(MONTH, -1, GETDATE())),
  @prevmonth = FORMAT(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0), N'yyyy-MM'),
  @prevmonthstart = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0),
  @prevmonthend = EOMONTH(DATEADD(MONTH, -2, GETDATE()));

SET @sql = N'
  DECLARE @RechAktuell TABLE (
    KundenID int,
    Nettoumsatz money
  );

  DECLARE @RechPrevious TABLE (
    KundenID int,
    Nettoumsatz money
  );

  INSERT INTO @RechAktuell (KundenID, Nettoumsatz)
  SELECT RechKo.KundenID, SUM(Rechko.NettoWert) AS Nettoumsatz
  FROM RechKo
  WHERE RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N''SMRO'')
    AND RechKo.RechDat BETWEEN @curmonthstart AND @curmonthend
    AND RechKo.[Status] > N''G''
    AND RechKo.[Status] < N''X''
  GROUP BY RechKo.KundenID;

  INSERT INTO @RechPrevious (KundenID, Nettoumsatz)
  SELECT RechKo.KundenID, SUM(Rechko.NettoWert) AS Nettoumsatz
  FROM RechKo
  WHERE RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N''SMRO'')
    AND RechKo.RechDat BETWEEN @prevmonthstart AND @prevmonthend
    AND RechKo.[Status] > N''G''
    AND RechKo.[Status] < N''X''
  GROUP BY RechKo.KundenID;

  SELECT Kunden.KdNr,
    Kunden.SuchCode AS Kunde,
    BrLauf.BrLaufBez AS Rechnungslauf,
    RechAktuell.Nettoumsatz AS [Umsatz ' + @curmonth + '],
    RechPrevious.Nettoumsatz AS [Umsatz ' + @prevmonth + '],
    RechAktuell.Nettoumsatz - RechPrevious.Nettoumsatz AS Differenz,
    CAST(ROUND(100 / IIF(RechPrevious.Nettoumsatz = 0, 1, RechPrevious.Nettoumsatz) * (RechAktuell.Nettoumsatz - RechPrevious.Nettoumsatz), 0) AS int) AS [%-Differenz]
  FROM @RechAktuell AS RechAktuell
  JOIN @RechPrevious AS RechPrevious ON RechAktuell.KundenID = RechPrevious.KundenID
  JOIN Kunden ON RechAktuell.KundenID = Kunden.ID
  JOIN BrLauf ON Kunden.BRLaufID = BrLauf.ID;
';

EXEC sp_executesql @sql, N'@curmonthstart date, @curmonthend date, @prevmonthstart date, @prevmonthend date', @curmonthstart, @curmonthend, @prevmonthstart, @prevmonthend;