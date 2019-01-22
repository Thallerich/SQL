-- ######## Step 1 ################################
BACKUP DATABASE Wozabal
TO DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal.bak'
WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, BUFFERCOUNT = 47, MAXTRANSFERSIZE = 4194304, MEDIANAME = N'AdvanTex-Backup', NAME = N'Full Backup of the AdvanTex-Database'

-- ######## Step 2 ################################

DECLARE @TestExists bit = 0;

IF db_id(N'Wozabal_Test') IS NOT NULL
  SET @TestExists = 1;

IF @TestExists = 1
  ALTER DATABASE Wozabal_Test
    SET SINGLE_USER
  WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE Wozabal_Test
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal.bak'
WITH RECOVERY, REPLACE,
  MOVE N'Wozabal' TO N'E:\SQL Server\MSSQL13.ADVANTEX\MSSQL\DATA\Wozabal_Test.mdf',
  MOVE N'Wozabal_Log' TO N'E:\SQL Server\MSSQL13.ADVANTEX\MSSQL\DATA\Wozabal_Test_Log.mdf';

IF @TestExists = 1
  ALTER DATABASE Wozabal_Test
    SET MULTI_USER
  WITH ROLLBACK AFTER 60 SECONDS;

-- ######## Step 3 ################################

BEGIN TRANSACTION;
  USE Wozabal_Test;

  UPDATE Settings
    SET [ValueMemo] = N'FFFF88'
    WHERE [Parameter] = N'COLOR_BACKGROUND';

  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENADVTEST.wozabal.int/webportal_20/upload/index.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENADVTEST.wozabal.int/webportal_20/upload/update.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP2';
    
  UPDATE Settings
    SET [ValueMemo] = N'_shadow'
    WHERE [Parameter] = N'WEB_IMPORT_SHADOW';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENADVTEST.wozabal.int/webportal_20/output/'
    WHERE [Parameter] = N'INTERNET_OUTPUT';	

  UPDATE Settings
    SET [ValueMemo] = N'/upload/data.sql'
    WHERE [Parameter] = N'INTERNET_TEMP_SQL';

  UPDATE Settings
    SET [ValueMemo] = N'1763'
    WHERE [Parameter] = N'WEBPORTAL_DOWNLOAD_PORT';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENADVTEST.wozabal.int/webportal_20/'
    WHERE [Parameter] = N'INTERNET_HTTP_URL';

  UPDATE Settings
    SET [ValueMemo] = N'a.wallas@salesianer.com'
    WHERE [Parameter] = N'WEBEXPORT_EMAIL';
    
  UPDATE Settings
    SET [ValueMemo] = N'SRVATENADVTEST.wozabal.int'
    WHERE [Parameter] = N'INTERNET_FTP_HOST';

  UPDATE Settings
    SET [ValueMemo] = N'webportal20'
    WHERE [Parameter] = N'INTERNET_FTP_USERNAME';	
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'WEB_UPLOAD_STARTED';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Data\WebDB_Test\'
    WHERE [Parameter] = N'WEB_EXPORT_UPLOAD_PATH';

  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Data\Logos\Wozabal_Miettex_Testsystem.bmp'
    WHERE [Parameter] = N'LOGO1_PATH_UND_DATEINAME';
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'LOGO2_PATH_UND_DATEINAME';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\advantex\data\UHFInventur\Testmandant\'
    WHERE [Parameter] = N'INVENTUR_UHF2_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\advantex\data\UHFInventur\Testmandant\Archiv\'
    WHERE [Parameter] = N'INVENTUR_UHF2_BACKUP_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\advantex\Data\Temp\'
    WHERE [Parameter] = N'PDF_SPOOL_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'CSV_FILENAME_INVENTURIMPORT';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\advantex\Data\Temp\'
    WHERE [Parameter] = N'REPORT_EXPORT_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/ConsignmentService.svc/SOAP'
    WHERE [Parameter] = N'URL_WS_COUNTIT_CONSIGNMENT';

  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/SortingService.svc/SOAP'
    WHERE [Parameter] = N'URL_WS_COUNTIT_SORTING';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/UncleanSideService.svc/SOAP'
    WHERE [Parameter] = N'URL_WS_COUNTIT_UNCLEANSIDE';
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'URL_WS_TAGSYS';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\advantex\data\EDI\EDI_Test\'
    WHERE [Parameter] = N'PATH_EOFFICE';

  UPDATE Settings
    SET [ValueMemo] = N'\\ATENADVANTEX01.wozabal.int\advantex\data\EDI\BMD_Test\'
    WHERE [Parameter] = N'PATH_BMD';
    
  UPDATE Rentomat 
    SET ExportFile1 = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Data\Export\Testmandant\'
    WHERE Rentomat.Interface <> 'Unimat';

  UPDATE Rentomat 
    SET FtpUsername = N'noFTPonlyTest'
    WHERE Rentomat.FtpUsername IS NOT NULL;

  UPDATE Rentomat 
    SET ExportFile1 = REPLACE(ExportFile1, '192.168.4.26', '127.0.0.1')
    WHERE Rentomat.Interface = N'Unimat';
    
  UPDATE ExpDef 
    SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\fibu\', N'\fibu\testmandant\')
    WHERE ExportFileName LIKE N'\\ATENADVANTEX01%';

  UPDATE ExpDef
    SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\scp\', N'\scq\')
    WHERE ExportFileName LIKE N'\\tsafile1.sal.co.at%';

  UPDATE ExpDef
    SET BackupFolder = RTRIM(BackupFolder) + N'Testmandant\'
    WHERE RIGHT(RTRIM(BackupFolder), 1) = N'\';

  UPDATE Settings
    SET ValueMemo = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Data\Rechnungsarchiv_Testmandant\'
    WHERE Parameter = N'PATH_RECHARCH';

  UPDATE RKoOut
    SET ArchivePath = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Export\Rechnungen_Testmandant\'
    WHERE ArchivePath IS NOT NULL;

  UPDATE RKoOut
    SET VersandPath = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Export\Rechnungen_Testmandant\'
    WHERE VersandPath IS NOT NULL;

COMMIT;

DBCC SHRINKFILE (Wozabal_Log);