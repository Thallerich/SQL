CREATE OR ALTER VIEW [sapbw].[V_BW_KUNDE] AS
  SELECT Kunden.KdNr AS Kundennummer,
    REPLACE(Kunden.SuchCode, CHAR(9), N' ') AS KundenBez_kurz,  /* CHAR(9) - Tabulator  -> durch Leerzeichen ersetzen */
    REPLACE(Kunden.Name1, CHAR(9), N' ') AS Kundenname1,
    REPLACE(Kunden.Name2, CHAR(9), N' ') AS Kundenname2,
    REPLACE(Kunden.Name3, CHAR(9), N' ') AS Kundenname3,
    Holding.Holding,
    Kunden.Strasse,
    Kunden.Ort,
    Kunden.PLZ,
    Kunden.Land,
    KdGf.KurzBez AS Branche,
    Kunden.Status AS KdStatus,
    Kunden.Debitor,
    IIF(Kunden.StatistikNum1 > 1, Kunden.StatistikNum1, Kunden.KdNr) AS Hauptkunde,
    Firma = 
      CASE Firma.SuchCode
        WHEN N'12' THEN N'MPZ'
        WHEN N'21' THEN N'TXS'
        WHEN N'31' THEN N'MBK'
        WHEN N'41' THEN N'LOG'
        WHEN N'42' THEN N'BHG'
        WHEN N'81' THEN N'MAN'
        WHEN N'91' THEN N'GAS'
        ELSE Firma.SuchCode
      END,
    DefaultBetrieb = IIF(Standort.SuchCode = N'SALESIANER MIET', SUBSTRING(Standort.Bez, CHARINDEX(N' ', Standort.Bez, 1) + 1, CHARINDEX(N':', Standort.Bez, 1) - CHARINDEX(N' ', Standort.Bez, 1) - 1), iif(Standort.Bez LIKE N'%ehem. Asten%','SMA', IIF(Kunden.KdNr = 15200, N'OWS', Standort.SuchCode))),
    Kunden.UStIdNr AS UIDNr,
    ZahlZiel.ZahlZiel,
    Kunden.StatistikNum4 AS Anz_Betten,
    Initialen = IIF(Kunden.Status = N'A' AND Firma.SuchCode = N'FA14', (
      SELECT TOP 1 ISNULL(UPPER(ISNULL(Mitarbei.Initialen, Mitarbei.UserName)), CAST(Mitarbei.ID AS nvarchar))
      FROM Salesianer.dbo.KdBer
      JOIN Salesianer.dbo.Mitarbei ON KdBer.BetreuerID = Mitarbei.ID
      WHERE KdBer.KundenID = Kunden.ID
      GROUP BY ISNULL(UPPER(ISNULL(Mitarbei.Initialen, Mitarbei.UserName)), CAST(Mitarbei.ID AS nvarchar))
      ORDER BY COUNT(*) DESC
    ), NULL)
  FROM Salesianer.dbo.Kunden
  JOIN Salesianer.dbo.Holding ON Kunden.HoldingID = Holding.ID
  JOIN Salesianer.dbo.KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Salesianer.dbo.Firma ON Kunden.FirmaID = Firma.ID
  JOIN Salesianer.dbo.Standort ON Kunden.StandortID = Standort.ID
  JOIN Salesianer.dbo.ZahlZiel ON Kunden.ZahlZielID = ZahlZiel.ID
  WHERE ( EXISTS (
      SELECT LsKo.*
      FROM Salesianer.dbo.LsKo
      JOIN Salesianer.dbo.Vsa ON LsKo.VsaID = Vsa.ID
      WHERE Vsa.KundenID = Kunden.ID
        AND LsKo.Datum >= N'2018-01-01'
    )
    OR EXISTS (
      SELECT RechKo.*
      FROM Salesianer.dbo.RechKo
      WHERE RechKo.KundenID = Kunden.ID
        AND RechKo.RechDat >= N'2018-01-01'
        AND RechKo.Status < N'Y'
    ));

GO