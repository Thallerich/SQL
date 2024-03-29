USE master;
GO

IF DB_ID(N'Salesianer_Test') IS NOT NULL AND DATABASEPROPERTYEX(N'Salesianer_Test', N'Status') = N'ONLINE'
  ALTER DATABASE Salesianer_Test
    SET SINGLE_USER
  WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE Salesianer_Test
  FROM DISK = N'\\10.10.203.16\mssql_backup\_temp\Salesianer.bak'
  WITH RECOVERY, REPLACE, STATS = 10,
    MOVE N'Salesianer' TO N'D:\SQL Server\UserDB\Salesianer_Test.mdf',
    MOVE N'Salesianer_Log' TO N'D:\SQL Server\TransactionLog\Salesianer_Test_Log.ldf';

ALTER DATABASE Salesianer_Test SET RECOVERY SIMPLE WITH NO_WAIT;

ALTER DATABASE Salesianer_Test MODIFY FILE (NAME = Salesianer, NEWNAME = Salesianer_Test);
ALTER DATABASE Salesianer_Test MODIFY FILE (NAME = Salesianer_log, NEWNAME = Salesianer_Test_log);

IF (SELECT DATABASEPROPERTYEX(N'Salesianer_Test', 'UserAccess')) = N'SINGLE_USER'
  ALTER DATABASE Salesianer_Test
    SET MULTI_USER
  WITH ROLLBACK AFTER 60 SECONDS;

GO

BEGIN TRANSACTION;

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'FFFF88'
    WHERE [Parameter] = N'COLOR_BACKGROUND';

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/upload_test_20210111/index.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/upload_test_20210111/index_http.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP_HTTP';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/upload_test_20210111/update.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP2';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/output_test_20210111/'
    WHERE [Parameter] = N'INTERNET_OUTPUT';	

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'/__wptest/upload_test_20210111/data.sql'
    WHERE [Parameter] = N'INTERNET_TEMP_SQL';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/'
    WHERE [Parameter] = N'INTERNET_HTTP_URL';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'/__wptest/output_test_20210111/'
    WHERE [Parameter] = N'INTERNET_OUTPUT_DIR';

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'/__wptest/upload_test_20210111/'
    WHERE [Parameter] = N'INTERNET_UPLOAD_DIR';

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'/__wptest/'
    WHERE [Parameter] = N'INTERNET_ROOT_DIR';

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\WebDB_Test\'
    WHERE [Parameter] = N'WEB_EXPORT_UPLOAD_PATH';

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Logo\Salesianer_LogoAdvanTex.bmp'
    WHERE [Parameter] = N'LOGO1_PATH_UND_DATEINAME';

  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\UHFInventur\Testmandant\'
    WHERE [Parameter] = N'INVENTUR_UHF2_PATH';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\UHFInventur\Testmandant\Archiv\'
    WHERE [Parameter] = N'INVENTUR_UHF2_BACKUP_PATH';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Temp\'
    WHERE [Parameter] = N'PDF_SPOOL_PATH';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Export\Inventurliste\Inventurliste.csv'
    WHERE [Parameter] = N'CSV_FILENAME_INVENTURIMPORT';
    
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Temp\'
    WHERE [Parameter] = N'REPORT_EXPORT_PATH';
    
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
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\EDI\EDI_Test\'
    WHERE [Parameter] = N'PATH_EOFFICE';
  
  UPDATE Salesianer_Test.dbo.Settings
    SET [ValueMemo] = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\EDI\BMD_Test\'
    WHERE [Parameter] = N'PATH_BMD';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'3048'
    WHERE Parameter = N'FAHRER_APP_PORT';

  UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'http://10.10.201.173:50000/XISOAPAdapter/MessageServlet'
      WHERE Parameter = N'SALSAP_WEBSERVICE_URL';

  UPDATE Salesianer_Test.dbo.Settings
      SET ValueMemo = N'AdvantexSOAP'
      WHERE Parameter = N'SALSAP_WEBSERVICE_SENDERSERVICE';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'~/''o+*=1%/;sx}~'
    WHERE Parameter = N'SALSAP_WEBSERVICE_PASSWORD';

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

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Dms\Document\'
    WHERE Parameter = N'PATH_DMS_DOCUMENT';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Dms\'
    WHERE Parameter = N'PATH_DMS_MASTERS';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\email\'
    WHERE Parameter = N'TEMP_ANHANG_PATH';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Regina\'
    WHERE Parameter = N'EXPORT_REGINA';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Temp\'
    WHERE Parameter = N'PATH_EXCEL';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\easybackup\'
    WHERE Parameter = N'INVENTUR_FTP_BACKUP_PATH';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\PflegeBackUp\'
    WHERE Parameter = N'OPETIBCIMPORT_BACKUP_PATH';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Rechnungsarchiv\'
    WHERE Parameter = N'PATH_RECHARCH';

  UPDATE Salesianer_Test.dbo.Settings
    SET ValueMemo = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\Mandant\Salesianer\'
    WHERE Parameter = N'DATA_PATH_MANDANT';

  UPDATE Salesianer_Test.dbo.Rentomat 
    SET ExportFile1 = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\DCS\Test\'
    WHERE Rentomat.Interface <> 'Unimat';

  UPDATE Salesianer_Test.dbo.Rentomat 
    SET FtpUsername = N'noFTPonlyTest'
    WHERE Rentomat.FtpUsername IS NOT NULL;

  UPDATE Salesianer_Test.dbo.Rentomat 
    SET ExportFile1 = REPLACE(ExportFile1, '192.168.4.26', '127.0.0.1')
    WHERE Rentomat.Interface = N'Unimat';
    
  UPDATE Salesianer_Test.dbo.ExpDef
    SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'salshdsvm09_681.salres.com', N'salsvattsamig1.sal.co.at')
    WHERE ExportFileName LIKE N'\\salshdsvm09_681.salres.com\advpapp_file\%'

  UPDATE Salesianer_Test.dbo.ExpDef
    SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\scp\', N'\scq\')
    WHERE ExportFileName LIKE N'\\tsafile1.sal.co.at%';

  UPDATE Salesianer_Test.dbo.ExpDef
    SET BackupFolder = REPLACE(ExpDef.BackupFolder, N'salshdsvm09_681.salres.com', N'salsvattsamig1.sal.co.at')
    WHERE BackupFolder LIKE N'%salshdsvm09_681.salres.com%';

  UPDATE Salesianer_Test.dbo.RKoOut
    SET ArchivePath = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\AdvanTex\Export\Rechnungen_Testmandant\'
    WHERE ArchivePath IS NOT NULL;

  UPDATE Salesianer_Test.dbo.RKoOut
    SET VersandPath = N'\\salsvattsamig1.sal.co.at\AdvanTex\Data\AdvanTex\Export\Rechnungen_Testmandant\'
    WHERE VersandPath IS NOT NULL;

COMMIT;

GO

USE Salesianer_Test;
DBCC SHRINKFILE (Salesianer_Test_log, 10240);
GO