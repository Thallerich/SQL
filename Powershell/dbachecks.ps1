Import-Module dbachecks;
Set-DbatoolsInsecureConnection -SessionOnly

Set-DbcConfig -Name app.sqlinstance -Value SVATGRAZSQL1.sal.co.at, SQL1FCIHQ22.sal.co.at, SVATSMWSQLC1.sal.co.at, SVATSMWWD1.sal.co.at, SVATINZSQL1.sal.co.at, SVATUMKLSQL1.sal.co.at, SVATLEOGSQL1.sal.co.at, SVATSAWRSQL1.sal.co.at, SVATSCHISQL1.sal.co.at, SVSKSMSKSQL1.sal.co.at, SQL1FCIEN.sal.co.at, SQL1FCIENCIT.sal.co.at, SVATWMLESQL1.sal.co.at
Set-DbcConfig -Name app.computername -Value SVATGRAZSQL1.sal.co.at, SVATSMWSQLC2.sal.co.at, SVATSMWSQLC1.sal.co.at, SVATSMWWD1.sal.co.at, SVATINZSQL1.sal.co.at, SVATUMKLSQL1.sal.co.at, SVATLEOGSQL1.sal.co.at, SVATSAWRSQL1.sal.co.at, SVATSCHISQL1.sal.co.at, SVSKSMSKSQL1.sal.co.at, SVATENSQLC1.sal.co.at, SVATENSQLC2.sal.co.at, SVATWMLESQL1.sal.co.at

Invoke-DbcCheck -Checks FailedJob, LongRunningJob, AgentAlert, LastJobRunTime, SuspectPage, InvalidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, LastFullBackup, LastDiffBackup, LastLogBackup, CompatibilityLevel, DatabaseStatus, QueryStoreEnabled, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan, DiskAllocationUnit, SPN -Credential sal\thalstadm -Show Summary -PassThru | Update-DbcPowerBiDataSource -Path "C:\Users\thalst.SAL\OneDrive - Salesianer Miettex GmbH\PowerBI\dbachecks"

# Start-DbcPowerBi