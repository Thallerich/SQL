/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Backup Database                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE master;
GO

BACKUP DATABASE Wozabal_Enns
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal_Enns.bak'
WITH STATS = 5, COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database';

GO

BACKUP DATABASE Wozabal_Enns_2
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal_Enns_2.bak'
WITH STATS = 5, COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database';

GO

BACKUP DATABASE dbSystem
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\dbSystem.bak'
WITH STATS = 5, COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Restore from Backup                                                                                                       ++ */
/* ++ Upgrade Compatibility Level to SQL Server 2019                                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE master;
GO

RESTORE DATABASE Salesianer_Enns_1
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal_Enns.bak'
WITH STATS = 5, RECOVERY, REPLACE,
  MOVE N'Wozabal_Enns' TO N'M:\DATA01\Salesianer_Enns_1.mdf',
  MOVE N'Wozabal_Enns_log' TO N'M:\LOG01\Salesianer_Enns_1.ldf';

GO

RESTORE DATABASE Salesianer_Enns_2
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal_Enns_2.bak'
WITH STATS = 5, RECOVERY, REPLACE,
  MOVE N'Wozabal_Enns_2' TO N'M:\DATA01\Salesianer_Enns_2.mdf',
  MOVE N'Wozabal_Enns_2_log' TO N'M:\LOG01\Salesianer_Enns_2.ldf';

GO

RESTORE DATABASE dbSystem
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\dbSystem.bak'
WITH STATS = 5, RECOVERY, REPLACE,
  MOVE N'dbSystem' TO N'M:\DATA01\dbSystem.mdf',
  MOVE N'dbSystem_log' TO N'M:\LOG01\dbSystem.ldf';

GO

ALTER DATABASE Salesianer_Enns_1 SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE Salesianer_Enns_2 SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE dbSystem SET COMPATIBILITY_LEVEL = 150;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Rename logical file names                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

ALTER DATABASE Salesianer_Enns_1 MODIFY FILE (NAME = Wozabal_Enns, NEWNAME = Salesianer_Enns_1);
ALTER DATABASE Salesianer_Enns_1 MODIFY FILE (NAME = Wozabal_Enns_log, NEWNAME = Salesianer_Enns_1_log);

GO

ALTER DATABASE Salesianer_Enns_2 MODIFY FILE (NAME = Wozabal_Enns_2, NEWNAME = Salesianer_Enns_2);
ALTER DATABASE Salesianer_Enns_2 MODIFY FILE (NAME = Wozabal_Enns_2_log, NEWNAME = Salesianer_Enns_2_log);

GO
