CREATE OR ALTER VIEW [sapbw].[V_BW_VSA] AS
  SELECT Vsa.VsaNr, Kunden.KdNr, Vsa.SuchCode, Vsa.Name1, Vsa.Name2, Vsa.Name3, Vsa.[Status], Vsa.Strasse, Vsa.PLZ, Vsa.Land, Vsa.Ort, IIF(Abteil.ID < 0, N'', Abteil.Abteilung) AS KstNr, Abteil.Bez AS KstBezeichnung, REPLACE(REPLACE(ISNULL(Abteil.RechnungsMemo, N''), CHAR(10), N''), CHAR(13), N'') AS RGInfoFeld, Vsa.Bez AS VSABez, StandKon.StandKonBez
  FROM Salesianer.dbo.Vsa
  JOIN Salesianer.dbo.Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Salesianer.dbo.Abteil ON Vsa.AbteilID = Abteil.ID
  JOIN Salesianer.dbo.StandKon ON Vsa.StandKonID = StandKon.ID
  WHERE EXISTS (
    SELECT LsKo.*
    FROM Salesianer.dbo.LsKo
    WHERE LsKo.VsaID = Vsa.ID
      AND LsKo.Datum >= N'2018-01-01'
  )
  OR EXISTS (
    SELECT RechPo.*
    FROM Salesianer.dbo.RechPo
    JOIN Salesianer.dbo.RechKo ON RechPo.RechKoID = RechKo.ID
    WHERE RechPo.VsaID = Vsa.ID
      AND RechKo.RechDat >= N'2018-01-01'
    );
GO

