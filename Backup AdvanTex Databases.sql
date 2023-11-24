/* GRAZ */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_Graz', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* HQ22 */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_SA22', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @Directory = N'\\svatsmwfp1.sal.co.at\sql-backups', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* INZ */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_Inzing', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* SAWR */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_SAWR', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* SMSK */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_SMSK', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* UMKL */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_Klagenfurt', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* WMEN */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Salesianer_Enns1, Salesianer_Enns_2', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* WMLE */
EXEC AdminDB.dbo.DatabaseBackup @Databases = N'Wozabal_Lenzing_1, Wozabal_Lenzing_2', @CopyOnly = N'Y', @BackupType = N'FULL', @Checksum = N'Y', @DirectoryStructure = NULL, @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}'
GO

/* Zentrale */
EXEC Salesianer_Archive.dbo.DatabaseBackup @Databases = N'Salesianer, OWS', @CopyOnly = N'Y', @BackupType = N'FULL', @Compress = N'Y', @Checksum = N'Y', @DirectoryStructure = NULL, @Directory = N'\\salshdsvm09_681.salres.com\mssql_backup\_temp\', @FileName = N'{DatabaseName}_{Year}{Month}{Day}{Hour}{Minute}{Second}_{CopyOnly}.{FileExtension}', @DirectoryCheck = N'N'
GO