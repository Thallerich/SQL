USE master;
GO

RESTORE DATABASE Wozabal
FROM DISK = N'\\ATENVCENTER01.wozabal.int\advbackup\Wozabal.bak'
WITH RECOVERY, REPLACE, STATS = 5,
  MOVE N'Wozabal' TO N'D:\AdvanTex\Data\SQL Server\MSSQL13.ADVANTEX\MSSQL\DATA\Wozabal.mdf',
  MOVE N'Wozabal_Log' TO N'D:\AdvanTex\Data\SQL Server\MSSQL13.ADVANTEX\MSSQL\DATA\Wozabal_log.ldf';

GO

BEGIN TRANSACTION;
  USE Wozabal;

  UPDATE Settings
    SET [ValueMemo] = N'FFFF88'
    WHERE [Parameter] = N'COLOR_BACKGROUND';

  UPDATE Settings
    SET [ValueMemo] = N'http://srvatenadvtest.wozabal.int/webportal_20/upload/index.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENADVTEST.wozabal.int/webportal_20/upload/index_http.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP_HTTP';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://srvatenadvtest.wozabal.int/webportal_20/upload/update.php'
    WHERE [Parameter] = N'INTERNET_IMPORT_PHP2';
    
  UPDATE Settings
    SET [ValueMemo] = N'_shadow'
    WHERE [Parameter] = N'WEB_IMPORT_SHADOW';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://srvatenadvtest.wozabal.int/webportal_20/output/'
    WHERE [Parameter] = N'INTERNET_OUTPUT';	

  UPDATE Settings
    SET [ValueMemo] = N'/upload/data.sql'
    WHERE [Parameter] = N'INTERNET_TEMP_SQL';

  UPDATE Settings
    SET [ValueMemo] = N'1763'
    WHERE [Parameter] = N'WEBPORTAL_DOWNLOAD_PORT';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://srvatenadvtest.wozabal.int/webportal_20/'
    WHERE [Parameter] = N'INTERNET_HTTP_URL';

  UPDATE Settings
    SET [ValueMemo] = N'a.wallas@wozabal.com'
    WHERE [Parameter] = N'WEBEXPORT_EMAIL';
    
  UPDATE Settings
    SET [ValueMemo] = N'srvatenadvtest.wozabal.int'
    WHERE [Parameter] = N'INTERNET_FTP_HOST';

  UPDATE Settings
    SET [ValueMemo] = N'webportal20'
    WHERE [Parameter] = N'INTERNET_FTP_USERNAME';	
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'WEB_UPLOAD_STARTED';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\AdvanTex\Data\WebDB\'
    WHERE [Parameter] = N'WEB_EXPORT_UPLOAD_PATH';

  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\AdvanTex\Data\Logos\Salesianer_LogoReleasetest.bmp'
    WHERE [Parameter] = N'LOGO1_PATH_UND_DATEINAME';
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'LOGO2_PATH_UND_DATEINAME';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\advantex\data\UHFInventur\'
    WHERE [Parameter] = N'INVENTUR_UHF2_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\advantex\data\UHFInventur\Archiv\'
    WHERE [Parameter] = N'INVENTUR_UHF2_BACKUP_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\advantex\Data\Temp\'
    WHERE [Parameter] = N'PDF_SPOOL_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'CSV_FILENAME_INVENTURIMPORT';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\advantex\Data\Temp\'
    WHERE [Parameter] = N'REPORT_EXPORT_PATH';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENCITTS01:8090/ConsignmentService.svc/SOAP'
    WHERE [Parameter] = N'URL_WS_COUNTIT_CONSIGNMENT';

  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENCITTS01:8090/SortingService.svc/SOAP'
    WHERE [Parameter] = N'URL_WS_COUNTIT_SORTING';
    
  UPDATE Settings
    SET [ValueMemo] = N'http://SRVATENCITTS01:8090/UncleanSideService.svc/SOAP'
    WHERE [Parameter] = N'URL_WS_COUNTIT_UNCLEANSIDE';
    
  UPDATE Settings
    SET [ValueMemo] = N''
    WHERE [Parameter] = N'URL_WS_TAGSYS';
    
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\advantex\data\EDI\EDI_Test\'
    WHERE [Parameter] = N'PATH_EOFFICE';
  
  UPDATE Settings
    SET [ValueMemo] = N'\\srvatenadvtest.wozabal.int\advantex\data\EDI\BMD_Test\'
    WHERE [Parameter] = N'PATH_BMD';

  UPDATE Rentomat 
    SET ExportFile1 = N'\\srvatenadvtest.wozabal.int\AdvanTex\Data\Export\'
    WHERE Rentomat.Interface <> 'Unimat';

  UPDATE Rentomat 
    SET FtpUsername = N'noFTPonlyTest'
    WHERE Rentomat.FtpUsername IS NOT NULL;

  UPDATE Rentomat 
    SET ExportFile1 = REPLACE(ExportFile1, '192.168.4.26', '127.0.0.1')
    WHERE Rentomat.Interface = N'Unimat';
    
  UPDATE ExpDef
    SET ExportFilename = N'\\srvatenadvtest.wozabal.int\AdvanTex\Data\FIBU\'
    WHERE ExportFilename LIKE N'\\atenadvantex01%';

  UPDATE ExpDef
    SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'\scp\', N'\scq\')
    WHERE ExportFileName LIKE N'\\tsafile1.sal.co.at%';

  UPDATE ExpDef
    SET BackupFolder = N'\\srvatenadvtest.wozabal.int\AdvanTex\Data\FIBU\Backup\'
    WHERE RIGHT(RTRIM(BackupFolder), 1) = N'\';

  UPDATE Settings
    SET ValueMemo = N'\\srvatenadvtest.wozabal.int\AdvanTex\Data\Rechnungsarchiv\'
    WHERE Parameter = N'PATH_RECHARCH';

  UPDATE Settings
    SET ValueMemo = N'\\srvatenadvtest.wozabal.int\advantex\data\help\'
    WHERE Parameter = N'WEBHELP_URL';

  UPDATE RKoOut
    SET ArchivePath = N'\\srvatenadvtest.wozabal.int\AdvanTex\Export\Rechnungen_Testmandant\'
    WHERE ArchivePath IS NOT NULL;

  UPDATE RKoOut
    SET VersandPath = N'\\srvatenadvtest.wozabal.int\AdvanTex\Export\Rechnungen_Testmandant\'
    WHERE VersandPath IS NOT NULL;

  DELETE
  FROM dbsystem.dbo.Sessions;

COMMIT;

ALTER DATABASE [Wozabal] SET NEW_BROKER WITH ROLLBACK IMMEDIATE;

DBCC SHRINKFILE (Wozabal_Log);