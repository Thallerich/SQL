USE dbsystem;
GO

GRANT SUBSCRIBE QUERY NOTIFICATIONS TO [salres\svc_advantexadmin];
GRANT RECEIVE ON QueryNotificationErrorsQueue TO [salres\svc_advantexadmin];
GRANT SUBSCRIBE QUERY NOTIFICATIONS TO [adssys];
GRANT RECEIVE ON QueryNotificationErrorsQueue TO [adssys];

GO

USE Salesianer;
GO

GRANT SUBSCRIBE QUERY NOTIFICATIONS TO [salres\svc_advantexadmin];
GRANT RECEIVE ON QueryNotificationErrorsQueue TO [salres\svc_advantexadmin];
GRANT SUBSCRIBE QUERY NOTIFICATIONS TO [adssys];
GRANT RECEIVE ON QueryNotificationErrorsQueue TO [adssys];

GO

USE OWS;
GO

GRANT SUBSCRIBE QUERY NOTIFICATIONS TO [salres\svc_advantexadmin];
GRANT RECEIVE ON QueryNotificationErrorsQueue TO [salres\svc_advantexadmin];
GRANT SUBSCRIBE QUERY NOTIFICATIONS TO [adssys];
GRANT RECEIVE ON QueryNotificationErrorsQueue TO [adssys];

GO