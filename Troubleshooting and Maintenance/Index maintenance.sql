EXECUTE Salesianer_Archive.dbo.IndexOptimize
@Databases = 'Salesianer',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE',
@FragmentationLevel1 = 50,
@FragmentationLevel2 = 80,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@SortInTempdb = 'Y'