BACKUP DATABASE LaundryAutomation
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\LaundryAutomation.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'LA-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE AdvanTexSync
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSync.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'AS-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE CustomerSystemTest
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\CustomerSystemTest.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'CST-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE EuroSortOptimierung
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\EuroSortOptimierung.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'ESO-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE PerformanceVisualization
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\PerformanceVisualization.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PV-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE PerformanceVisualizationTest
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\PerformanceVisualizationTest.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'PVT-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE LaundryAutomationTest
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\LaundryAutomationTest.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'LAT-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE AdvanTexSyncTest
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSyncTest.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'AST-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE AdvantexSync_Log_Temp
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvantexSync_Log_Temp.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'ASLT-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO

BACKUP DATABASE CustomerSystem
  TO DISK = N'\\atenvcenter01.wozabal.int\advbackup\CustomerSystem.bak'
  WITH COPY_ONLY, COMPRESSION, INIT, SKIP, FORMAT, MEDIANAME = N'CS-Backup', NAME = N'Copy-Only Backup', STATS = 10;

GO