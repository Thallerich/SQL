RESTORE DATABASE LaundryAutomation
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\LaundryAutomation.bak'
WITH RECOVERY, REPLACE, STATS = 10,
  MOVE N'LaundryAutomation' TO N'M:\DATA01\LaundryAutomation.mdf',
  MOVE N'LaundryAutomation_log' TO N'M:\LOG01\LaundryAutomation_log.ldf';

GO

RESTORE DATABASE AdvanTexSync
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSync.bak'
WITH RECOVERY, REPLACE,
  MOVE N'AdvanTexSync' TO N'M:\DATA01\AdvanTexSync.mdf',
  MOVE N'AdvanTexSync_log' TO N'M:\LOG01\AdvanTexSync_log.ldf';

GO

RESTORE DATABASE CustomerSystemTest
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\CustomerSystemTest.bak' 
WITH RECOVERY, REPLACE,
  MOVE N'CustomerSystem' TO N'M:\DATA01\CustomerSystemTest.mdf',
  MOVE N'CustomerSystem_log' TO N'M:\LOG01\CustomerSystemTest_log.ldf';

GO

RESTORE DATABASE EuroSortOptimierung
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\EuroSortOptimierung.bak'
WITH RECOVERY, REPLACE,
  MOVE N'EuroSortOptimierung' TO N'M:\DATA01\EuroSortOptimierung.mdf',
  MOVE N'EuroSortOptimierung_log' TO N'M:\LOG01\EuroSortOptimierung_log.ldf';

GO

RESTORE DATABASE PerformanceVisualization
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\PerformanceVisualization.bak'
WITH RECOVERY, REPLACE,
  MOVE N'PerformanceVisualization' TO N'M:\DATA01\PerformanceVisualization.mdf',
  MOVE N'PerformanceVisualization_log' TO N'M:\LOG01\PerformanceVisualization_log.ldf';

GO

RESTORE DATABASE PerformanceVisualizationTest
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\PerformanceVisualizationTest.bak'
WITH RECOVERY, REPLACE,
  MOVE N'PerformanceVisualization' TO N'M:\DATA01\PerformanceVisualizationTest.mdf',
  MOVE N'PerformanceVisualization_log' TO N'M:\LOG01\PerformanceVisualizationTest_log.ldf';

GO

RESTORE DATABASE LaundryAutomationTest
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\LaundryAutomationTest.bak'
WITH RECOVERY, REPLACE,
  MOVE N'LaundryAutomation' TO N'M:\DATA01\LaundryAutomationTest.mdf',
  MOVE N'LaundryAutomation_log' TO N'M:\LOG01\LaundryAutomationTest_log.ldf';

GO

RESTORE DATABASE AdvanTexSyncTest
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvanTexSyncTest.bak'
WITH RECOVERY, REPLACE,
  MOVE N'AdvanTexSync' TO N'M:\DATA01\AdvanTexSyncTest.mdf',
  MOVE N'AdvanTexSync_log' TO N'M:\LOG01\AdvanTexSyncTest_log.ldf';

GO

RESTORE DATABASE AdvantexSync_Log_Temp
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\AdvantexSync_Log_Temp.bak'
WITH RECOVERY, REPLACE,
  MOVE N'AdvantexSync_Log_Temp' TO N'M:\DATA01\AdvantexSync_Log_Temp.mdf',
  MOVE N'AdvantexSync_Log_Temp_log' TO N'M:\LOG01\AdvantexSync_Log_Temp_log.ldf';

GO

RESTORE DATABASE CustomerSystem
FROM DISK = N'\\atenvcenter01.wozabal.int\advbackup\CustomerSystem.bak'
WITH RECOVERY, REPLACE,
  MOVE N'CustomerSystem' TO N'M:\DATA01\CustomerSystem.mdf',
  MOVE N'CustomerSystem_log' TO N'M:\LOG01\CustomerSystem_log.ldf';

GO