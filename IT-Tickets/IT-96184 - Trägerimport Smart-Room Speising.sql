DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

INSERT INTO Traeger (VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Geschlecht, Indienst, IndienstDat, RentomatKarte, RentoArtID, RentoCodID, RentomatKredit, AnlageUserID_, UserID_)
SELECT Vsa.ID AS VsaID, N'A' AS [Status], _IT96184.Träger AS Traeger, COALESCE(Abteil1.ID, Abteil2.ID) AS AbteilID, _IT96184.PersNr AS PersNr, _IT96184.Vorname, _IT96184.Nachname, ISNULL(Vornamen.Geschlecht, N'?') AS Geschlecht, @currentweek AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, _IT96184.Chipkartennummer AS RentomatKarte, 2 AS RentoArtID, ISNULL(RentoCod.ID, -1) AS RentoCodID, ISNULL(RentoCod.KreditVorschlag, 0) AS RentomatKredit, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM _IT96184
LEFT JOIN Vsa ON _IT96184.VsaNr = Vsa.VsaNr AND Vsa.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 20156)
LEFT JOIN Abteil AS Abteil1 ON _IT96184.KoSt = Abteil1.Abteilung AND Abteil1.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 20156)
LEFT JOIN Abteil AS Abteil2 ON TRY_CAST(_IT96184.KoSt AS int) = TRY_CAST(Abteil2.Abteilung AS int) AND Abteil2.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 20156)
LEFT JOIN Vornamen ON UPPER(_IT96184.Vorname) = Vornamen.Vorname
LEFT JOIN RentoCod ON RentoCod.RentomatID = Vsa.RentomatID AND _IT96184.Funktionscode = RentoCod.Bez
WHERE NOT EXISTS (
  SELECT Traeger.*
  FROM Traeger
  WHERE Traeger.VsaID = Vsa.ID
    AND Traeger.RentomatKarte = _IT96184.Chipkartennummer
);

--TRUNCATE TABLE _IT96184