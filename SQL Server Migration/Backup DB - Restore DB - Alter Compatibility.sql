/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Backup Database                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE master;
GO

BACKUP DATABASE Salesianer_SMSK_SDC
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Salesianer_SMSK.bak'
WITH STATS = 5, COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Restore from Backup                                                                                                       ++ */
/* ++ Upgrade Compatibility Level to SQL Server 2019                                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

USE master;
GO

RESTORE DATABASE Salesianer_SMSK
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Salesianer_SMSK.bak'
WITH STATS = 5, RECOVERY, REPLACE,
  MOVE N'Wozabal_Lenzing_2' TO N'M:\DATA01\Salesianer_SMSK.mdf',
  MOVE N'Wozabal_Lenzing_2_log' TO N'M:\LOG01\Salesianer_SMSK_log.ldf';

GO

ALTER DATABASE Salesianer_SMSK SET COMPATIBILITY_LEVEL = 150;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Rename logical file names                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

ALTER DATABASE Salesianer_SMSK MODIFY FILE (NAME = Wozabal_Lenzing_2, NEWNAME = Salesianer_SMSK);
ALTER DATABASE Salesianer_SMSK MODIFY FILE (NAME = Wozabal_Lenzing_2_log, NEWNAME = Salesianer_SMSK_log);

GO