UPDATE Touren SET TourKatID = 5
WHERE Touren.Tour LIKE N'_-37800' OR Touren.Tour LIKE N'_-37804' OR Touren.Tour LIKE N'_-37808' OR Touren.Tour LIKE N'_-37816' OR Touren.Tour LIKE N'_-37820' OR Touren.Tour LIKE N'_-37824' OR Touren.Tour LIKE N'_-37828' OR Touren.Tour LIKE N'_-37832' OR Touren.Tour LIKE N'_-37812';

GO

UPDATE Touren SET TourKatID = 6
WHERE Touren.Tour LIKE N'_-37801' OR Touren.Tour LIKE N'_-37805' OR Touren.Tour LIKE N'_-37809' OR Touren.Tour LIKE N'_-37817' OR Touren.Tour LIKE N'_-37821' OR Touren.Tour LIKE N'_-37825' OR Touren.Tour LIKE N'_-37829' OR Touren.Tour LIKE N'_-37833' OR Touren.Tour LIKE N'_-37813';

GO

UPDATE Touren SET TourKatID = 7
WHERE Touren.Tour LIKE N'_-37802' OR Touren.Tour LIKE N'_-37806' OR Touren.Tour LIKE N'_-37810' OR Touren.Tour LIKE N'_-37818' OR Touren.Tour LIKE N'_-37822' OR Touren.Tour LIKE N'_-37826' OR Touren.Tour LIKE N'_-37830' OR Touren.Tour LIKE N'_-37834' OR Touren.Tour LIKE N'_-37814';

GO

UPDATE Touren SET TourKatID = 8
WHERE Touren.Tour LIKE N'_-37803' OR Touren.Tour LIKE N'_-37815' OR Touren.Tour LIKE N'_-37807' OR Touren.Tour LIKE N'_-37811' OR Touren.Tour LIKE N'_-37819' OR Touren.Tour LIKE N'_-37823' OR Touren.Tour LIKE N'_-37827' OR Touren.Tour LIKE N'_-37831' OR Touren.Tour LIKE N'_-37835';

GO

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO [Filter] (TableName, FilterBez, FilterBez1, FilterBez2, FilterBez3, FilterBez4, FilterBez5, FilterBez6, FilterBez7, FilterBez8, AddCond, Info, UserID_, AnlageUserID_)
VALUES (N'VSATOUR', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'TILAK 06:00 Uhr', N'o.TourenID IN (SELECT Touren.ID FROM Touren WHERE Touren.TourKatID = 5)', N'Filter für Klinik Innsbruck', @UserID, @UserID);

INSERT INTO [Filter] (TableName, FilterBez, FilterBez1, FilterBez2, FilterBez3, FilterBez4, FilterBez5, FilterBez6, FilterBez7, FilterBez8, AddCond, Info, UserID_, AnlageUserID_)
VALUES (N'VSATOUR', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'TILAK 09:00 Uhr', N'o.TourenID IN (SELECT Touren.ID FROM Touren WHERE Touren.TourKatID = 6)', N'Filter für Klinik Innsbruck', @UserID, @UserID);

INSERT INTO [Filter] (TableName, FilterBez, FilterBez1, FilterBez2, FilterBez3, FilterBez4, FilterBez5, FilterBez6, FilterBez7, FilterBez8, AddCond, Info, UserID_, AnlageUserID_)
VALUES (N'VSATOUR', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'TILAK 12:00 Uhr', N'o.TourenID IN (SELECT Touren.ID FROM Touren WHERE Touren.TourKatID = 7)', N'Filter für Klinik Innsbruck', @UserID, @UserID);

INSERT INTO [Filter] (TableName, FilterBez, FilterBez1, FilterBez2, FilterBez3, FilterBez4, FilterBez5, FilterBez6, FilterBez7, FilterBez8, AddCond, Info, UserID_, AnlageUserID_)
VALUES (N'VSATOUR', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'TILAK 18:00 Uhr', N'o.TourenID IN (SELECT Touren.ID FROM Touren WHERE Touren.TourKatID = 8)', N'Filter für Klinik Innsbruck', @UserID, @UserID);

GO