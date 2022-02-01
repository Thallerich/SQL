BACKUP DATABASE Reporting
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\Reporting.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'Reporting-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO