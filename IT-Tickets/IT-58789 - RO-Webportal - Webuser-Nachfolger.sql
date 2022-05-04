DECLARE @ChangeLog TABLE (
  Username nvarchar(80),
  FullName nvarchar(40),
  eMail nvarchar(80)
);

BEGIN TRANSACTION;

  UPDATE WebUser SET UserName = REPLACE(UserName, N'NEGRIO', N'ZODIIU'), FullName = N'Iulian ZODIE', eMail = N'i.zodie@salesianer.ro'
  OUTPUT inserted.UserName, inserted.FullName, inserted.eMail
  INTO @ChangeLog
  WHERE Webuser.UserName LIKE N'NEGRIO%';

COMMIT;