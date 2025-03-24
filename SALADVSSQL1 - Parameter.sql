SET NOCOUNT ON;

DECLARE @srvname nchar(10) = (SELECT LEFT(@@SERVERNAME, 10));

IF @srvname = N'saladvssql'
BEGIN

  BEGIN TRANSACTION;

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'B75766'
      WHERE [Parameter] = N'COLOR_BACKGROUND';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/upload_test_20210111/index.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/upload_test_20210111/index_http.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP_HTTP';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/upload_test_20210111/update.php'
      WHERE [Parameter] = N'INTERNET_IMPORT_PHP2';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/output_test_20210111/'
      WHERE [Parameter] = N'INTERNET_OUTPUT';	

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'/__wptest/upload_test_20210111/data.sql'
      WHERE [Parameter] = N'INTERNET_TEMP_SQL';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'https://kunden-test.salesianer.com/__wptest/'
      WHERE [Parameter] = N'INTERNET_HTTP_URL';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'/__wptest/output_test_20210111/'
      WHERE [Parameter] = N'INTERNET_OUTPUT_DIR';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'/__wptest/upload_test_20210111/'
      WHERE [Parameter] = N'INTERNET_UPLOAD_DIR';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'/__wptest/'
      WHERE [Parameter] = N'INTERNET_ROOT_DIR';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\WebDB_Test\'
      WHERE [Parameter] = N'WEB_EXPORT_UPLOAD_PATH';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Logos\Salesianer_LogoReleasetest.bmp'
      WHERE [Parameter] = N'LOGO1_PATH_UND_DATEINAME';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\UHFInventur\Testmandant\'
      WHERE [Parameter] = N'INVENTUR_UHF2_PATH';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\UHFInventur\Testmandant\Archiv\'
      WHERE [Parameter] = N'INVENTUR_UHF2_BACKUP_PATH';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\advantex\Data\Temp\'
      WHERE [Parameter] = N'PDF_SPOOL_PATH';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Export\Inventurliste\Inventurliste.csv'
      WHERE [Parameter] = N'CSV_FILENAME_INVENTURIMPORT';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\advantex\Data\Temp\'
      WHERE [Parameter] = N'REPORT_EXPORT_PATH';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/ConsignmentService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_CONSIGNMENT';

    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/SortingService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_SORTING';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'http://SRVATENCITTS01.wozabal.int:8090/UncleanSideService.svc/SOAP'
      WHERE [Parameter] = N'URL_WS_COUNTIT_UNCLEANSIDE';
      
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\EDI\EDI_Test\'
      WHERE [Parameter] = N'PATH_EOFFICE';
    
    UPDATE Salesianer.dbo.Settings
      SET [ValueMemo] = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\EDI\BMD_Test\'
      WHERE [Parameter] = N'PATH_BMD';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'3048'
      WHERE Parameter = N'FAHRER_APP_PORT';

    UPDATE Salesianer.dbo.Settings
        SET ValueMemo = N'http://10.10.201.173:50000/XISOAPAdapter/MessageServlet'
        WHERE Parameter = N'SALSAP_WEBSERVICE_URL';

    UPDATE Salesianer.dbo.Settings
        SET ValueMemo = N'AdvantexStagingSOAP'
        WHERE Parameter = N'SALSAP_WEBSERVICE_SENDERSERVICE';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'~/''o+*=1%/;sx}~'
      WHERE Parameter = N'SALSAP_WEBSERVICE_PASSWORD';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'10.10.200.195'
      WHERE Parameter = N'ABS_HOSTNAME';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'~./~5 z%#;#z~'
      WHERE Parameter = N'ABS_PASSWORT';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'ABST12C'
      WHERE Parameter = N'ABS_SERVICE_NAME';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'training01'
      WHERE Parameter = N'ABS_USERNAME';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Dms\Document\'
      WHERE Parameter = N'PATH_DMS_DOCUMENT';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Dms\'
      WHERE Parameter = N'PATH_DMS_MASTERS';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\email\'
      WHERE Parameter = N'TEMP_ANHANG_PATH';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Regina\'
      WHERE Parameter = N'EXPORT_REGINA';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Temp\'
      WHERE Parameter = N'PATH_EXCEL';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\easybackup\'
      WHERE Parameter = N'INVENTUR_FTP_BACKUP_PATH';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\PflegeBackUp\'
      WHERE Parameter = N'OPETIBCIMPORT_BACKUP_PATH';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Rechnungsarchiv\'
      WHERE Parameter = N'PATH_RECHARCH';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\Mandant\Salesianer\'
      WHERE Parameter = N'DATA_PATH_MANDANT';

    UPDATE Salesianer.dbo.Rentomat 
      SET ExportFile1 = N'\\SALADVSAPP1.salres.com\DCS\Test\'
      WHERE Rentomat.Interface <> 'Unimat';

    UPDATE Salesianer.dbo.Rentomat 
      SET FtpUsername = N'noFTPonlyTest'
      WHERE Rentomat.FtpUsername IS NOT NULL;

    UPDATE Salesianer.dbo.Rentomat 
      SET ExportFile1 = REPLACE(ExportFile1, '192.168.4.26', '127.0.0.1')
      WHERE Rentomat.Interface = N'Unimat';
      
    UPDATE Salesianer.dbo.ExpDef
      SET ExportFileName = REPLACE(ExpDef.ExportFileName, N'salshdsvm09_681.salres.com\advpapp_file\', N'\\SALADVSAPP1.salres.com\')
      WHERE ExportFileName LIKE N'\\salshdsvm09_681.salres.com\advpapp_file\%'

    UPDATE Salesianer.dbo.ExpDef
      SET BackupFolder = REPLACE(ExpDef.ExportFileName, N'salshdsvm09_681.salres.com\advpapp_file\', N'\\SALADVSAPP1.salres.com\')
      WHERE BackupFolder LIKE N'%salshdsvm09_681.salres.com\advpapp_file\%';

    UPDATE Salesianer.dbo.RKoOut
      SET ArchivePath = N'\\SALADVSAPP1.salres.com\AdvanTex\Export\Rechnungen_Testmandant\'
      WHERE ArchivePath IS NOT NULL;

    UPDATE Salesianer.dbo.RKoOut
      SET VersandPath = N'\\SALADVSAPP1.salres.com\AdvanTex\Export\Rechnungen_Testmandant\'
      WHERE VersandPath IS NOT NULL;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ AdvanTex Online - Webportal                                                                                               ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'/'
      WHERE Parameter = N'LIVE_FTP_DIRECTORY';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'9099'
      WHERE Parameter = N'LIVE_SERVER_PORT';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'saladftptest1'
      WHERE Parameter = N'LIVE_FTP_USERNAME';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'~$<e-.z0*#*~'
      WHERE Parameter = N'LIVE_FTP_PASSWORD';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'https://testportal.salesianer.com/'
      WHERE Parameter = N'LIVE_URL';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\SSL\Salesianer_Wildcard_aktuell.crt'
      WHERE Parameter = N'LIVE_SSL_CERT_FILE';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\SSL\Salesianer_Wildcard_aktuell.key'
      WHERE Parameter = N'LIVE_SSL_KEY_FILE';

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ AdvanTex Apps - Allgemein                                                                                                 ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\SSL\Salesianer_Wildcard_aktuell.crt'
      WHERE Parameter = N'MOBSYNC_SSL_CERTIFICATE';

    UPDATE Salesianer.dbo.Settings
      SET ValueMemo = N'\\SALADVSAPP1.salres.com\AdvanTex\Data\SSL\Salesianer_Wildcard_aktuell.key'
      WHERE Parameter = N'MOBSYNC_SSL_KEY';

  COMMIT;

END
ELSE
  PRINT N'WARNING! - Server name incorrect - check server!';
GO