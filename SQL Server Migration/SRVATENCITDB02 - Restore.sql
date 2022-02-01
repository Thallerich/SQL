RESTORE DATABASE AdvanTexSyncLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSyncLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'AdvanTexSyncLog' TO N'M:\DATA01\AdvanTexSyncLog.mdf',
  MOVE N'AdvanTexSyncLog_log' TO N'M:\LOG01\AdvanTexSyncLog_log.ldf';

GO

RESTORE DATABASE AdvanTexSyncTestLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSyncTestLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'AdvanTexSyncTestLog' TO N'M:\DATA01\AdvanTexSyncTestLog.mdf',
  MOVE N'AdvanTexSyncTestLog_log' TO N'M:\LOG01\AdvanTexSyncTestLog_log.ldf';

GO

RESTORE DATABASE ArrivalLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ArrivalLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ArrivalLog' TO N'M:\DATA01\ArrivalLog.mdf',
  MOVE N'ArrivalLog_log' TO N'M:\LOG01\ArrivalLog_log.ldf';

GO

RESTORE DATABASE ConsignmentLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ConsignmentLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ConsignmentLog' TO N'M:\DATA01\ConsignmentLog.mdf',
  MOVE N'ConsignmentLog_log' TO N'M:\LOG01\ConsignmentLog_log.ldf';

GO

RESTORE DATABASE EurosortLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\EurosortLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'EurosortLog' TO N'M:\DATA01\EurosortLog.mdf',
  MOVE N'EurosortLog_log' TO N'M:\LOG01\EurosortLog_log.ldf';

GO

RESTORE DATABASE FuturailLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\FuturailLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'FuturailLog' TO N'M:\DATA01\FuturailLog.mdf',
  MOVE N'FuturailLog_log' TO N'M:\LOG01\FuturailLog_log.ldf';

GO

RESTORE DATABASE GUILog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\GUILog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'GUILog' TO N'M:\DATA01\GUILog.mdf',
  MOVE N'GUILog_log' TO N'M:\LOG01\GUILog_log.ldf';

GO

RESTORE DATABASE HandLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\HandLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'HandLog' TO N'M:\DATA01\HandLog.mdf',
  MOVE N'HandLog_log' TO N'M:\LOG01\HandLog_log.ldf';

GO

RESTORE DATABASE IldefonsoLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\IldefonsoLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'IldefonsoLog' TO N'M:\DATA01\IldefonsoLog.mdf',
  MOVE N'IldefonsoLog_log' TO N'M:\LOG01\IldefonsoLog_log.ldf';

GO

RESTORE DATABASE JenrailLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\JenrailLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'JenrailLog' TO N'M:\DATA01\JenrailLog.mdf',
  MOVE N'JenrailLog_log' TO N'M:\LOG01\JenrailLog_log.ldf';

GO

RESTORE DATABASE ProductionLog_Budweis
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Budweis.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Budweis' TO N'M:\DATA01\ProductionLog_Budweis.mdf',
  MOVE N'ProductionLog_Budweis_log' TO N'M:\LOG01\ProductionLog_Budweis_log.ldf';

GO

RESTORE DATABASE ProductionLog_Enns
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Enns.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Enns' TO N'M:\DATA01\ProductionLog_Enns.mdf',
  MOVE N'ProductionLog_Enns_log' TO N'M:\LOG01\ProductionLog_Enns_log.ldf';

GO

RESTORE DATABASE ProductionLog_Lenzing
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Lenzing.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Lenzing' TO N'M:\DATA01\ProductionLog_Lenzing.mdf',
  MOVE N'ProductionLog_Lenzing_log' TO N'M:\LOG01\ProductionLog_Lenzing_log.ldf';

GO

RESTORE DATABASE ProductionLog_Linz
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Linz.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Linz' TO N'M:\DATA01\ProductionLog_Linz.mdf',
  MOVE N'ProductionLog_Linz_log' TO N'M:\LOG01\ProductionLog_Linz_log.ldf';

GO

RESTORE DATABASE ProductionLog_Produktion_GP_Enns
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Produktion_GP_Enns.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Produktion_GP_Enns' TO N'M:\DATA01\ProductionLog_Produktion_GP_Enns.mdf',
  MOVE N'ProductionLog_Produktion_GP_Enns_log' TO N'M:\LOG01\ProductionLog_Produktion_GP_Enns_log.ldf';

GO

RESTORE DATABASE Productionlog_Rankweil
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\Productionlog_Rankweil.bak'
WITH RECOVERY, REPLACE,
  MOVE N'Productionlog_Rankweil' TO N'M:\DATA01\Productionlog_Rankweil.mdf',
  MOVE N'Productionlog_Rankweil_log' TO N'M:\LOG01\Productionlog_Rankweil_log.ldf';

GO

RESTORE DATABASE ProductionLog_Test
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Test.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Test' TO N'M:\DATA01\ProductionLog_Test.mdf',
  MOVE N'ProductionLog_Test_log' TO N'M:\LOG01\ProductionLog_Test_log.ldf';

GO

RESTORE DATABASE ProductionLog_Umlauft
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Umlauft.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Umlauft' TO N'M:\DATA01\ProductionLog_Umlauft.mdf',
  MOVE N'ProductionLog_Umlauft_log' TO N'M:\LOG01\ProductionLog_Umlauft_log.ldf';

GO

RESTORE DATABASE SushiTowerLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\SushiTowerLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'SushiTowerLog' TO N'M:\DATA01\SushiTowerLog.mdf',
  MOVE N'SushiTowerLog_log' TO N'M:\LOG01\SushiTowerLog_log.ldf';

GO

RESTORE DATABASE CustomerLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\CustomerLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'CustomerLog' TO N'M:\DATA01\CustomerLog.mdf',
  MOVE N'CustomerLog_log' TO N'M:\LOG01\CustomerLog_log.ldf';

GO

RESTORE DATABASE PerformanceVisualizationLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\PerformanceVisualizationLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'PerformanceVisualizationLog' TO N'M:\DATA01\PerformanceVisualizationLog.mdf',
  MOVE N'PerformanceVisualizationLog_log' TO N'M:\LOG01\PerformanceVisualizationLog_log.ldf';

GO

RESTORE DATABASE PositioningLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\PositioningLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'PositioningLog' TO N'M:\DATA01\PositioningLog.mdf',
  MOVE N'PositioningLog_log' TO N'M:\LOG01\PositioningLog_log.ldf';

GO

RESTORE DATABASE MoxaCoordinatorLog
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\MoxaCoordinatorLog.bak'
WITH RECOVERY, REPLACE,
  MOVE N'MoxaCoordinatorLog' TO N'M:\DATA01\MoxaCoordinatorLog.mdf',
  MOVE N'MoxaCoordinatorLog_log' TO N'M:\LOG01\MoxaCoordinatorLog_log.ldf';

GO

RESTORE DATABASE API_Log
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\API_Log.bak'
WITH RECOVERY, REPLACE,
  MOVE N'API_Log' TO N'M:\DATA01\API_Log.mdf',
  MOVE N'API_Log_log' TO N'M:\LOG01\API_Log_log.ldf';

GO

RESTORE DATABASE ArrivalLog_StPoelten
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ArrivalLog_StPoelten.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ArrivalLog_StPoelten' TO N'M:\DATA01\ArrivalLog_StPoelten.mdf',
  MOVE N'ArrivalLog_StPoelten_log' TO N'M:\LOG01\ArrivalLog_StPoelten_log.ldf';

GO

RESTORE DATABASE ProductionLog_Brasov
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Brasov.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_Brasov' TO N'M:\DATA01\ProductionLog_Brasov.mdf',
  MOVE N'ProductionLog_Brasov_log' TO N'M:\LOG01\ProductionLog_Brasov_log.ldf';

GO

RESTORE DATABASE ProductionLog_SCHI
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_SCHI.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_SCHI' TO N'M:\DATA01\ProductionLog_SCHI.mdf',
  MOVE N'ProductionLog_SCHI_log' TO N'M:\LOG01\ProductionLog_SCHI_log.ldf';

GO

RESTORE DATABASE ArrivalLog_StPoelten
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ArrivalLog_StPoelten.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ArrivalLog_StPoelten' TO N'M:\DATA01\ArrivalLog_StPoelten.mdf',
  MOVE N'ArrivalLog_StPoelten_log' TO N'M:\LOG01\ArrivalLog_StPoelten_log.ldf';

GO

RESTORE DATABASE ProductionLog_SMZL
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_SMZL.bak'
WITH RECOVERY, REPLACE,
  MOVE N'ProductionLog_SMZL' TO N'M:\DATA01\ProductionLog_SMZL.mdf',
  MOVE N'ProductionLog_SMZL_log' TO N'M:\LOG01\ProductionLog_SMZL_log.ldf';

GO

RESTORE DATABASE IldefonsoLog2
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\IldefonsoLog2.bak'
WITH RECOVERY, REPLACE,
  MOVE N'IldefonsoLog2' TO N'M:\DATA01\IldefonsoLog2.mdf',
  MOVE N'IldefonsoLog2_log' TO N'M:\LOG01\IldefonsoLog2_log.ldf';

GO