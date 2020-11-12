-- ######## Step 1 ################################
BACKUP DATABASE Wozabal
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal.bak'
WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database';

-- ######## Step 2 ################################

IF db_id(N'Wozabal_Test') IS NOT NULL AND DATABASEPROPERTYEX(N'Wozabal_Test', N'Status') = N'ONLINE'
  ALTER DATABASE Wozabal_Test
    SET SINGLE_USER
  WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE Wozabal_Test
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal.bak'
WITH RECOVERY, REPLACE,
  MOVE N'Wozabal' TO N'T:\Wozabal_Test\Wozabal_Test.mdf',
  MOVE N'Wozabal_Log' TO N'T:\Wozabal_Test\Wozabal_Test_Log.ldf';

IF (SELECT DATABASEPROPERTYEX(N'Wozabal_Test', 'UserAccess')) = N'SINGLE_USER'
  ALTER DATABASE Wozabal_Test
    SET MULTI_USER
  WITH ROLLBACK AFTER 60 SECONDS;

-- ######## Step 3 ################################

DECLARE @role tinyint;

SET @role = (
  SELECT [role]
  FROM [sys].[dm_hadr_availability_replica_states] hars 
  INNER JOIN [sys].[availability_databases_cluster] adc ON hars.[group_id] = adc.[group_id]
  WHERE hars.[is_local] = 1
  AND adc.[database_name] = N'Salesianer_Test'
);

IF @role = 1 
BEGIN

  BEGIN TRANSACTION;

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'FFFF88'
      WHERE [Parameter] = N'COLOR_BACKGROUND';

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/upload/index.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP';

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/upload/index_http.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP_HTTP';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/upload/update.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP2';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/output/'
      WHERE [Parameter] = N'INTERNET_OUTPUT';	

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'/upload/data.sql'
      WHERE [Parameter] = N'INTERNET_TEMP_SQL';

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'11683'
      WHERE [Parameter] = N'WEBPORTAL_DOWNLOAD_PORT';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/'
      WHERE [Parameter] = N'INTERNET_HTTP_URL';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\WebDB_Test\'
      WHERE [Parameter] = N'WEB_EXPORT_UPLOAD_PATH';

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\Logos\Salesianer_LogoTestmandant.bmp'
      WHERE [Parameter] = N'LOGO1_PATH_UND_DATEINAME';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\UHFInventur\Testmandant\'
      WHERE [Parameter] = N'INVENTUR_UHF2_PATH';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\UHFInventur\Testmandant\Archiv\'
      WHERE [Parameter] = N'INVENTUR_UHF2_BACKUP_PATH';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N''
      WHERE [Parameter] = N'CSV_FILENAME_INVENTURIMPORT';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/ConsignmentService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_CONSIGNMENT';

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/SortingService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_SORTING';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/UncleanSideService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_UNCLEANSIDE';
      
    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\EDI\EDI_Test\'
      WHERE [Parameter] = N'PATH_EOFFICE';

    UPDATE Salesianer_Test.dbo.Settings
      SET [ValueMemo] = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\EDI\BMD_Test\'
      WHERE [Parameter] = N'PATH_BMD';
      
    UPDATE Salesianer_Test.dbo.Rentomat 
      SET ExportFile1 = N'\SALADVPAPP1.salres.com\AdvanTex\Data\Export\Test\'
      WHERE Rentomat.Interface <> 'Unimat';

    UPDATE Salesianer_Test.dbo.Rentomat 
      SET FtpUsername = N'noFTPonlyTest'
      WHERE Rentomat.FtpUsername IS NOT NULL;

    UPDATE Salesianer_Test.dbo.Rentomat 
      SET ExportFile1 = REPLACE(ExportFile1, '192.168.4.26', '127.0.0.1')
      WHERE Rentomat.Interface = N'Unimat';
      
    UPDATE Salesianer_Test.dbo.ExpDef 
      SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\fibu\', N'\fibu\testmandant\')
      WHERE ExportFileName LIKE N'\\SALADVPAPP1.salres.com%';

    UPDATE Salesianer_Test.dbo.ExpDef
      SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\scp\', N'\scq\')
      WHERE ExportFileName LIKE N'\\tsafile1.sal.co.at%';

    UPDATE Salesianer_Test.dbo.ExpDef
      SET BackupFolder = RTRIM(BackupFolder) + N'Testmandant\'
      WHERE RIGHT(RTRIM(BackupFolder), 1) = N'\';

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'\\SALADVPAPP1.salres.com\AdvanTex\Data\Rechnungsarchiv_Testmandant\'
      WHERE Parameter = N'PATH_RECHARCH';

    UPDATE Salesianer_Test.dbo.RKoOut
      SET ArchivePath = N'\SALADVPAPP1.salres.com\AdvanTex\Data\Export\Rechnungen_Testmandant\'
      WHERE ArchivePath IS NOT NULL;

    UPDATE Salesianer_Test.dbo.RKoOut
      SET VersandPath = N'\\\SALADVPAPP1.salres.com\AdvanTex\Data\Export\Rechnungen_Testmandant\'
      WHERE VersandPath IS NOT NULL;

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'3048'
      WHERE Parameter = N'FAHRER_APP_PORT';

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'http://10.10.201.173:50400/XISOAPAdapter/MessageServlet'
      WHERE Parameter = N'SALSAP_WEBSERVICE_URL';

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'10.10.200.195'
      WHERE Parameter = N'ABS_HOSTNAME';

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'~./~5 z%#;#z~'
      WHERE Parameter = N'ABS_PASSWORT';

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'ABST12C'
      WHERE Parameter = N'ABS_SERVICE_NAME';

    UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'training01'
      WHERE Parameter = N'ABS_USERNAME';

  COMMIT;

END;