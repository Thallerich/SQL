/* DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO Traeger (VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Geschlecht, Indienst, IndienstDat, RentomatKarte, RentoArtID, ChipSerienNummer, AnlageUserID_, UserID_)
SELECT KDKVsa.ID AS VsaID, N'A' AS [Status], ROW_NUMBER() OVER (ORDER BY _SmartRoomKOR_Traeger.Nachname) + 3 AS Traeger, KDKVsa.AbteilID, _SmartRoomKOR_Traeger.Personalnummer AS PersNr, _SmartRoomKOR_Traeger.Vorname, _SmartRoomKOR_Traeger.Nachname, ISNULL(Vornamen.Geschlecht, N'?') AS Geschlecht, @currentweek AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, _SmartRoomKOR_Traeger.Token AS RentomatKarte, 2 AS RentoArtID, _SmartRoomKOR_Traeger.KartenID AS ChipSeriennummer, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM _SmartRoomKOR_Traeger
CROSS JOIN (
  SELECT Vsa.*
  FROM Vsa
  WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006751)
) AS KDKVsa
LEFT JOIN Vornamen ON UPPER(_SmartRoomKOR_Traeger.Vorname) = Vornamen.Vorname;

GO */

DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @maxtnr int = (SELECT MAX(CAST(Traeger.Traeger AS int)) FROM Traeger WHERE Traeger.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006751)))

INSERT INTO Traeger (VsaID, [Status], Traeger, AbteilID, PersNr, Vorname, Nachname, Geschlecht, Indienst, IndienstDat, RentomatKarte, RentoArtID, ChipSerienNummer, AnlageUserID_, UserID_)
SELECT KDKVsa.ID AS VsaID, N'A' AS [Status], ROW_NUMBER() OVER (ORDER BY _SmartRoomKOR_Traeger_3.Nachname) + @maxtnr AS Traeger, KDKVsa.AbteilID, _SmartRoomKOR_Traeger_3.Personalnummer AS PersNr, _SmartRoomKOR_Traeger_3.Vorname, _SmartRoomKOR_Traeger_3.Nachname, ISNULL(Vornamen.Geschlecht, N'?') AS Geschlecht, @currentweek AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, _SmartRoomKOR_Traeger_3.Token AS RentomatKarte, 2 AS RentoArtID, _SmartRoomKOR_Traeger_3.[KartenID] AS ChipSeriennummer, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM _SmartRoomKOR_Traeger_3
CROSS JOIN (
  SELECT Vsa.*
  FROM Vsa
  WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006751)
) AS KDKVsa
LEFT JOIN Vornamen ON UPPER(_SmartRoomKOR_Traeger_3.Vorname) = Vornamen.Vorname
WHERE NOT EXISTS (
  SELECT Traeger.*
  FROM Traeger
  WHERE Traeger.VsaID = KDKVsa.ID
    AND Traeger.ChipSerienNummer = _SmartRoomKOR_Traeger_3.[KartenID]
);

GO

INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, MengeKredit)
SELECT Kundenträger.VsaID, Kundenträger.ID AS TraegerID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID, _SmartRoomKOR_Traegerartikel.Kredite AS MengeKredit
FROM _SmartRoomKOR_Traegerartikel
JOIN (
  SELECT Traeger.*
  FROM Traeger
  WHERE Traeger.VsaID IN (
    SELECT Vsa.ID
    FROM Vsa
    WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006751)
  )
) AS Kundenträger ON Kundenträger.ChipSerienNummer = _SmartRoomKOR_Traegerartikel.KartenID
JOIN Artikel ON _SmartRoomKOR_Traegerartikel.ArtikelNr = Artikel.ArtikelNr
JOIN ArtGroe ON _SmartRoomKOR_Traegerartikel.Groesse = ArtGroe.Groesse AND ArtGroe.ArtikelID = Artikel.ID
JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 10006751);

GO