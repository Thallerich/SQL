BACKUP DATABASE AdvanTexSyncLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSyncLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'ASL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE AdvanTexSyncTestLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSyncTestLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'ASTL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ArrivalLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ArrivalLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'AL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ConsignmentLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ConsignmentLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'CL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE EurosortLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\EurosortLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'EL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE FuturailLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\FuturailLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'FL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE GUILog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\GUILog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'GL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE HandLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\HandLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'HL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE IldefonsoLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\IldefonsoLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'IL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE JenrailLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\JenrailLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'JL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Budweis
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Budweis.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLB-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Enns
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Enns.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLE-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Lenzing
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Lenzing.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Linz
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Linz.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Produktion_GP_Enns
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Produktion_GP_Enns.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLE-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE Productionlog_Rankweil
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\Productionlog_Rankweil.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLR-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Test
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Test.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLT-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Umlauft
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Umlauft.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLU-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE SushiTowerLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\SushiTowerLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'STL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE CustomerLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\CustomerLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'CL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE PerformanceVisualizationLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\PerformanceVisualizationLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PVL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE PositioningLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\PositioningLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE MoxaCoordinatorLog
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\MoxaCoordinatorLog.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'MCL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE API_Log
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\API_Log.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'AL-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ArrivalLog_StPoelten
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ArrivalLog_StPoelten.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'ALS-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_Brasov
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_Brasov.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLB-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_SCHI
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_SCHI.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLS-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ArrivalLog_StPoelten
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ArrivalLog_StPoelten.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'ALS-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE ProductionLog_SMZL
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\ProductionLog_SMZL.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PLS-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE IldefonsoLog2
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\IldefonsoLog2.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'IL2-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO