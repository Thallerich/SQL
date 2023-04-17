DECLARE @MailRemove nvarchar(100) = N'p.peischl@salesianer.com';

SELECT ParamPattern,
  MailTo,
  REPLACE(IIF(RIGHT(IIF(LEFT(REPLACE(LOWER(MailTo), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailTo), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailTo), @MailRemove, N'')), 1) = N';', REVERSE(STUFF(REVERSE(IIF(LEFT(REPLACE(LOWER(MailTo), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailTo), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailTo), @MailRemove, N''))), 1, 1, N'')), IIF(LEFT(REPLACE(LOWER(MailTo), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailTo), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailTo), @MailRemove, N''))), N';;', N';') AS MailTo_New,
  MailCC,
  REPLACE(IIF(RIGHT(IIF(LEFT(REPLACE(LOWER(MailCC), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailCC), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailCC), @MailRemove, N'')), 1) = N';', REVERSE(STUFF(REVERSE(IIF(LEFT(REPLACE(LOWER(MailCC), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailCC), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailCC), @MailRemove, N''))), 1, 1, N'')), IIF(LEFT(REPLACE(LOWER(MailCC), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailCC), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailCC), @MailRemove, N''))), N';;', N';') AS MailCC
FROM MailDefination
WHERE (MailTo LIKE (N'%' + @MailRemove + N'%') OR MailCC LIKE (N'%' + @MailRemove + N'%'));

/*
UPDATE MailDefination SET
  MailTo = REPLACE(IIF(RIGHT(IIF(LEFT(REPLACE(LOWER(MailTo), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailTo), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailTo), @MailRemove, N'')), 1) = N';', REVERSE(STUFF(REVERSE(IIF(LEFT(REPLACE(LOWER(MailTo), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailTo), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailTo), @MailRemove, N''))), 1, 1, N'')), IIF(LEFT(REPLACE(LOWER(MailTo), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailTo), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailTo), @MailRemove, N''))), N';;', N';'),
  MailCC = REPLACE(IIF(RIGHT(IIF(LEFT(REPLACE(LOWER(MailCC), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailCC), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailCC), @MailRemove, N'')), 1) = N';', REVERSE(STUFF(REVERSE(IIF(LEFT(REPLACE(LOWER(MailCC), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailCC), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailCC), @MailRemove, N''))), 1, 1, N'')), IIF(LEFT(REPLACE(LOWER(MailCC), @MailRemove, N''), 1) = N';', STUFF(REPLACE(LOWER(MailCC), @MailRemove, N''), 1, 1, N''), REPLACE(LOWER(MailCC), @MailRemove, N''))), N';;', N';')
FROM MailDefination
WHERE (MailTo LIKE (N'%' + @MailRemove + N'%') OR MailCC LIKE (N'%' + @MailRemove + N'%'));
*/