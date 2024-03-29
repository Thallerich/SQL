DECLARE @role tinyint;

SET @role = (
  SELECT [role]
  FROM [sys].[dm_hadr_availability_replica_states] AS hars 
  JOIN [sys].[availability_databases_cluster] AS adc ON hars.[group_id] = adc.[group_id]
  WHERE hars.[is_local] = 1
    AND adc.[database_name] = N'Salesianer'
);

IF @role = 1 
BEGIN

  IF db_id(N'Salesianer_RechTest') IS NOT NULL AND DATABASEPROPERTYEX(N'Salesianer_RechTest', N'Status') = N'ONLINE'
    ALTER DATABASE Salesianer_RechTest
      SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

  RESTORE DATABASE Salesianer_RechTest
  FROM DISK = N'\\salshdsvm09_681.salres.com\mssql_backup\_temp\Salesianer.bak'
  WITH RECOVERY, REPLACE,
    MOVE N'Salesianer' TO N'E:\DATA\Salesianer_RechTest.mdf',
    MOVE N'Salesianer_Log' TO N'E:\LOG\Salesianer_RechTest_Log.ldf';

  ALTER DATABASE Salesianer_RechTest SET RECOVERY SIMPLE WITH NO_WAIT;

  IF (SELECT DATABASEPROPERTYEX(N'Salesianer_RechTest', 'UserAccess')) = N'SINGLE_USER'
    ALTER DATABASE Salesianer_RechTest
      SET MULTI_USER
    WITH ROLLBACK AFTER 60 SECONDS;

  BEGIN TRANSACTION;

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'FFFF88'
      WHERE [Parameter] = N'COLOR_BACKGROUND';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/upload/index.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/upload/index_http.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP_HTTP';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/upload/update.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP2';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/output/'
      WHERE [Parameter] = N'INTERNET_OUTPUT';	

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'/upload/data.sql'
      WHERE [Parameter] = N'INTERNET_TEMP_SQL';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'11683'
      WHERE [Parameter] = N'WEBPORTAL_DOWNLOAD_PORT';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'https://kunden.salesianer.com/test/'
      WHERE [Parameter] = N'INTERNET_HTTP_URL';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\WebDB_Test\'
      WHERE [Parameter] = N'WEB_EXPORT_UPLOAD_PATH';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Logos\Salesianer_LogoRechTest.bmp'
      WHERE [Parameter] = N'LOGO1_PATH_UND_DATEINAME';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\UHFInventur\Testmandant\'
      WHERE [Parameter] = N'INVENTUR_UHF2_PATH';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\UHFInventur\Testmandant\Archiv\'
      WHERE [Parameter] = N'INVENTUR_UHF2_BACKUP_PATH';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N''
      WHERE [Parameter] = N'CSV_FILENAME_INVENTURIMPORT';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/ConsignmentService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_CONSIGNMENT';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/SortingService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_SORTING';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/UncleanSideService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_UNCLEANSIDE';
      
    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\EDI\EDI_Test\'
      WHERE [Parameter] = N'PATH_EOFFICE';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET [ValueMemo] = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\EDI\BMD_Test\'
      WHERE [Parameter] = N'PATH_BMD';
      
    UPDATE Salesianer_RechTest.dbo.Rentomat 
      SET ExportFile1 = N'\\salshdsvm09_681.salres.com\advpapp_file\DCS\Test\'
      WHERE Rentomat.Interface <> 'Unimat';

    UPDATE Salesianer_RechTest.dbo.Rentomat 
      SET FtpUsername = N'noFTPonlyTest'
      WHERE Rentomat.FtpUsername IS NOT NULL;

    UPDATE Salesianer_RechTest.dbo.Rentomat 
      SET ExportFile1 = REPLACE(ExportFile1, '192.168.4.26', '127.0.0.1')
      WHERE Rentomat.Interface = N'Unimat';
      
    UPDATE Salesianer_RechTest.dbo.ExpDef 
      SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\fibu\', N'\fibu\testmandant\')
      WHERE ExportFileName LIKE N'\\salshdsvm09_681.salres.com\advpapp_file\%';

    UPDATE Salesianer_RechTest.dbo.ExpDef
      SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\scp\', N'\scq\')
      WHERE ExportFileName LIKE N'\\tsafile1.sal.co.at%';

    UPDATE Salesianer_RechTest.dbo.ExpDef
      SET BackupFolder = RTRIM(BackupFolder) + N'Testmandant\'
      WHERE RIGHT(RTRIM(BackupFolder), 1) = N'\';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Rechnungsarchiv_Testmandant\'
      WHERE Parameter = N'PATH_RECHARCH';

    UPDATE Salesianer_RechTest.dbo.RKoOut
      SET ArchivePath = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Export\Rechnungen_Testmandant\'
      WHERE ArchivePath IS NOT NULL;

    UPDATE Salesianer_RechTest.dbo.RKoOut
      SET VersandPath = N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Export\Rechnungen_Testmandant\'
      WHERE VersandPath IS NOT NULL;

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'3048'
      WHERE Parameter = N'FAHRER_APP_PORT';
  
    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'3057'
      WHERE Parameter = N'FAHRER_APP_UHF_PORT';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'http://10.10.201.173:50000/XISOAPAdapter/MessageServlet'
      WHERE Parameter = N'SALSAP_WEBSERVICE_URL';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'~/''o+*=1%/;sx}~'
      WHERE Parameter = N'SALSAP_WEBSERVICE_PASSWORD';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'10.10.200.195'
      WHERE Parameter = N'ABS_HOSTNAME';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'~./~5 z%#;#z~'
      WHERE Parameter = N'ABS_PASSWORT';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'ABST12C'
      WHERE Parameter = N'ABS_SERVICE_NAME';

    UPDATE Salesianer_RechTest.dbo.Settings
      SET ValueMemo = N'training01'
      WHERE Parameter = N'ABS_USERNAME';

  COMMIT;

END;
