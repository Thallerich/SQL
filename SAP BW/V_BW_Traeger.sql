CREATE OR ALTER VIEW [sapbw].[V_BW_Traeger] AS
  SELECT UPPER(Traeger.Traeger) AS Traeger, Traeger.Nachname, ISNULL(Traeger.Vorname + N' ', N'') + ISNULL(Traeger.Nachname, N'') AS Name1, UPPER(ISNULL(Traeger.PersNr, N'')) AS PersNr, Vsa.VsaNr, Kunden.KdNr
  FROM Salesianer.dbo.Traeger
  JOIN Salesianer.dbo.Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Salesianer.dbo.Kunden ON Vsa.KundenID = Kunden.ID;