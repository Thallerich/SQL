DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

INSERT INTO Traeger (VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Geschlecht, Indienst, IndienstDat, RentomatKarte, RentoArtID, RentoCodID, RentomatKredit, AnlageUserID_, UserID_)
SELECT Vsa.ID AS VsaID, N'A' AS [Status], _IT101114.Traeger AS Traeger, Abteil.ID AS AbteilID, CAST(_IT101114.PersNr AS nvarchar(10)) AS PersNr, _IT101114.Vorname, _IT101114.Nachname, ISNULL(Vornamen.Geschlecht, N'?') AS Geschlecht, @currentweek AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, _IT101114.Chipkartennummer AS RentomatKarte, 2 AS RentoArtID, ISNULL(RentoCod.ID, -1) AS RentoCodID, _IT101114.Gesamtkontingent AS RentomatKredit, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM _IT101114
LEFT JOIN Kunden ON _IT101114.KdNr = Kunden.KdNr
LEFT JOIN Vsa ON _IT101114.VsaNr = Vsa.VsaNr AND Vsa.KundenID = Kunden.ID
LEFT JOIN Abteil ON _IT101114.Kostenstelle = Abteil.Abteilung AND Abteil.KundenID = Kunden.ID
LEFT JOIN Vornamen ON UPPER(_IT101114.Vorname) = Vornamen.Vorname
LEFT JOIN RentoCod ON RentoCod.RentomatID = Vsa.RentomatID AND _IT101114.Funktionscode = RentoCod.Funktionscode
WHERE NOT EXISTS (
  SELECT Traeger.*
  FROM Traeger
  WHERE Traeger.VsaID = Vsa.ID
    AND Traeger.RentomatKarte = _IT101114.Chipkartennummer
);

--TRUNCATE TABLE _IT101114