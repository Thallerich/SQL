SET NOCOUNT ON;
GO

DECLARE @LSText nvarchar(max);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

SET @LSText = CHAR(13) + CHAR(10) + N'Sehr geehrter SALESIANER Kunde,' + CHAR(13) + CHAR(10) + N'haben Sie in der anstehenden Weihnachtszeit / Silvester Schließtage oder einen Betriebsurlaub geplant?' + CHAR(13) + CHAR(10) + N'Geben Sie unserem Kundenservice schon jetzt per E-Mail an @MailParam Bescheid, damit wir Ihre reibungslose Versorgung sicherstellen können.';

INSERT INTO VsaTexte (KundenID, TextArtID, Memo, VonDatum, BisDatum, AnlageUserID_, UserID_)
SELECT Kunden.ID AS KundenID, 2 AS TextArtID, REPLACE(@LSText, N'@MailParam', _IT75057.[Mail-Adresse]) AS Memo, CAST(GETDATE() AS date) AS VonDatum, CAST(N'2023-12-31' AS date) AS BisDatum, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Salesianer.dbo._IT75057 ON [Zone].ZonenCode = _IT75057.Vertriebszone COLLATE Latin1_General_CS_AS
  AND KdGf.KurzBez = _IT75057.Geschäftsbereich COLLATE Latin1_General_CS_AS
  AND (Standort.SuchCode = _IT75057.Hauptstandort COLLATE Latin1_General_CS_AS OR _IT75057.Hauptstandort IS NULL)
WHERE Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Kunden.FirmaID = 5260;

GO