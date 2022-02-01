RESTORE DATABASE Reporting
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\Reporting.bak'
WITH RECOVERY, REPLACE,
  MOVE N'Reporting' TO N'M:\DATA01\Reporting.mdf',
  MOVE N'Reporting_log' TO N'M:\LOG01\Reporting_log.ldf';

GO