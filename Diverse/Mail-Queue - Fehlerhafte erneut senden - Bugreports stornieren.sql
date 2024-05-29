/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reporting                                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* 
SELECT MailQue.Subject, MailQue.Recipient, MailQue.MailAttempts, MailQue.SendZeit, MailQue.QueueZeit, MailQue.ErrorLog, IIF(DATEDIFF(hour, MailQue.SendZeit, MailQue.QueueZeit) < -1, CAST(1 AS bit), CAST(0 AS bit)) AS [was Error Mail?], IIF(MailQue.[Status] = N'Q', CAST(1 AS bit), CAST(0 AS bit)) AS [Success?]
FROM MailQue
WHERE MailQue.[Status] IN (N'Q', N'S')
  AND MailQue.SendZeit > DATEADD(minute, -10, GETDATE())
ORDER BY SendZeit ASC;

GO
 */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Bugreport stornieren                                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

UPDATE MailQue SET [Status] = N'X', ErrorLog = CONCAT(FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss'), N': Statuswechsel von „', [Status].StatusBez, N'“ zu „storniert“', CHAR(13) + CHAR(10), CHAR(13) + CHAR(10), ErrorLog), UserID_ = @userid
FROM [Status] 
WHERE MailQue.[Status] = [Status].[Status]
  AND [Status].Tabelle = N'MAILQUE'
  AND MailQue.Recipient = N'bugs@advantex.de'
  AND MailQue.QueueZeit > N'2024-05-27 00:00:00.000'
  AND MailQue.[Status] IN (N'A', N'S');

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Fehlermail reset                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

WITH FailedMail AS (
  SELECT TOP 30 MailQue.ID, AppendErrorLog = CONCAT(FORMAT(GETDATE(), N'dd.MM.yyyy HH:mm:ss'), N': Statuswechsel von „', [Status].StatusBez, N'“ zu „erfasst“', CHAR(13) + CHAR(10), CHAR(13) + CHAR(10))
  FROM MailQue
  JOIN [Status] ON MailQue.[Status] = [Status].[Status]
    AND [Status].Tabelle = N'MAILQUE'
    AND MailQue.QueueZeit > N'2024-05-27 00:00:00.000'
    AND MailQue.[Status] = N'S'
  ORDER BY MailQue.QueueZeit ASC
)
UPDATE MailQue SET [Status] = N'A', MailAttempts = 0, VersandMitarbeiID = -2, ErrorLog = CONCAT(FailedMail.AppendErrorLog, MailQue.ErrorLog), UserID_ = @userid
FROM FailedMail
WHERE MailQue.ID = FailedMail.ID;

GO