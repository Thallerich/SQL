USE master;
GO

BACKUP DATABASE Salesianer_SAWR
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Salesianer_SAWR.bak'
WITH STATS = 5, COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2020-07-14                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE master;
GO

RESTORE DATABASE Salesianer_SAWR
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Salesianer_SAWR.bak'
WITH STATS = 5, RECOVERY, REPLACE,
  MOVE N'Salesianer_SAWR' TO N'M:\DATA01\Salesianer_SAWR.mdf',
  MOVE N'Salesianer_SAWR_log' TO N'M:\LOG01\Salesianer_SAWR_log.ldf';

GO

ALTER DATABASE Salesianer_SAWR SET COMPATIBILITY_LEVEL = 150;

GO