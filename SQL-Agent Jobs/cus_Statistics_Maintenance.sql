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

  EXEC Salesianer_Archive.dbo.IndexOptimize
    @Databases = N'Salesianer',
    @Indexes = N'ALL_INDEXES',
    @FragmentationLow = NULL,
    @FragmentationMedium = NULL,
    @FragmentationHigh = NULL,
    @FragmentationLevel1 = 50,
    @FragmentationLevel2 = 80,
    @UpdateStatistics = N'ALL',
    @OnlyModifiedStatistics = N'Y',
    @StatisticsSample = 100,
    @StatisticsPersistSample = N'Y',
    @WaitAtLowPriorityMaxDuration = 300,
    @WaitAtLowPriorityAbortAfterWait = N'SELF',
    @LogToTable = N'Y';

END;