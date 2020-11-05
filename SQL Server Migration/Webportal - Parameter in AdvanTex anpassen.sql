USE Wozabal_Test;
GO

UPDATE Settings SET ValueMemo = N'212.31.69.228' WHERE Parameter = N'INTERNET_FTP_HOST';
UPDATE Settings SET ValueMemo = N'2222' WHERE Parameter = N'INTERNET_FTP_SSL_PORT';
UPDATE Settings SET ValueMemo = N'1' WHERE Parameter = N'INTERNET_FTP_USE_SSH';
UPDATE Settings SET ValueMemo = N'saladftp1' WHERE Parameter = N'INTERNET_FTP_USERNAME';
UPDATE Settings SET ValueMemo = N'https://kunden-test.salesianer.com/' WHERE Parameter = N'INTERNET_HTTP_URL';
UPDATE Settings SET ValueMemo = N'https://kunden-test.salesianer.com/upload_20201020/index.php' WHERE Parameter = N'INTERNET_IMPORT_PHP';
UPDATE Settings SET ValueMemo = N'https://kunden-test.salesianer.com/upload_20201020/index_http.php' WHERE Parameter = N'INTERNET_IMPORT_PHP_HTTP';
UPDATE Settings SET ValueMemo = N'https://kunden-test.salesianer.com/upload_20201020/update.php' WHERE Parameter = N'INTERNET_IMPORT_PHP2';
UPDATE Settings SET ValueMemo = N'https://kunden-test.salesianer.com/output_20201020/' WHERE Parameter = N'INTERNET_OUTPUT';
UPDATE Settings SET ValueMemo = N'/output_20201020/' WHERE Parameter = N'INTERNET_OUTPUT_DIR';
UPDATE Settings SET ValueMemo = N'/' WHERE Parameter = N'INTERNET_ROOT_DIR';
UPDATE Settings SET ValueMemo = N'/upload_20201020/data.sql' WHERE Parameter = N'INTERNET_TEMP_SQL';
UPDATE Settings SET ValueMemo = N'/upload_20201020/' WHERE Parameter = N'INTERNET_UPLOAD_DIR';
UPDATE Settings SET ValueMemo = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Data\WebDB_Test' WHERE Parameter = N'WEB_EXPORT_UPLOAD_PATH';
UPDATE Settings SET ValueMemo = N's.thaller@salesianer.com' WHERE Parameter = N'WEBEXPORT_EMAIL';
UPDATE Settings SET ValueMemo = N's.thaller@salesianer.com' WHERE Parameter = N'WEBIMPORT_EMAIL';

GO