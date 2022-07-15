DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRANSACTION;
  INSERT INTO Traeger (VsaID, Traeger, AbteilID, Titel, Vorname, Nachname, Geschlecht, Indienst, IndienstDat, AnlageUserID_, UserID_)
  SELECT Vsa.ID AS VsaID, RIGHT(REPLICATE(N'0', 4) + CAST(_TraegerImport.Traeger AS nvarchar), 4) AS Traeger, Abteil.ID AS AbteilID, LEFT(_TraegerImport.Titel, 20) AS Titel, LEFT(_TraegerImport.Vorname, 20) AS Vorname, LEFT(_TraegerImport.Nachname, 25) AS Nachname, ISNULL(Vornamen.Geschlecht, N'?') AS Geschlecht, Week.Woche AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM _TraegerImport
  CROSS JOIN Week
  JOIN Vsa ON _TraegerImport.VsaNr = Vsa.VsaNr
  JOIN Kunden ON _TraegerImport.KdNr = Kunden.KdNr AND Vsa.KundenID = Kunden.ID
  JOIN Abteil ON _TraegerImport.Kostenstelle COLLATE Latin1_General_CS_AS = Abteil.Abteilung AND Abteil.KundenID = Kunden.ID
  LEFT JOIN Vornamen ON UPPER(_TraegerImport.Vorname) COLLATE Latin1_General_CS_AS = Vornamen.Vorname
  WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat;

COMMIT;

GO

DROP TABLE IF EXISTS _TraegerImport;
GO