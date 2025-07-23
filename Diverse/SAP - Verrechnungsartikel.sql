SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ArtiType.ArtiTypeBez, ArtiType.ID AS ArtiTypeID, Artikel.Update_, Mitarbei.MitarbeiUser
FROM Artikel
JOIN ArtiType ON Artikel.ArtiTypeID = ArtiType.ID
JOIN Mitarbei ON Artikel.UserID_ = Mitarbei.ID
WHERE Artikel.ArtikelNr IN (
  SELECT N'VA_' + Bereich.Bereich
  FROM Bereich
);

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @ArtiFix TABLE (ArtikelID int);

INSERT INTO @ArtiFix (ArtikelID)
SELECT Artikel.ID
FROM Artikel
WHERE Artikel.ArtiTypeID != 7
  AND Artikel.ArtikelNr IN (
    SELECT N'VA_' + Bereich.Bereich
    FROM Bereich
  );

UPDATE Artikel SET ArtiTypeID = 7, UserID_ = @userid
WHERE ID IN (SELECT ArtikelID FROM @ArtiFix);

GO