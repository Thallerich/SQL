Import-Module dbachecks;
Set-DbatoolsInsecureConnection -SessionOnly

$cred = Get-Credential -Username "sal\thalstadm" -Message "Please enter your password: "

Write-Host "Checking production environment"
Invoke-DbcCheck -SqlInstance SVATGRAZSQL1.sal.co.at, SVATINZSQL1.sal.co.at, SVATUMKLSQL1.sal.co.at, SVATLEOGSQL1.sal.co.at, SVATSAWRSQL1.sal.co.at,SVATSCHISQL1.sal.co.at, SVSKSMSKSQL1.sal.co.at, SVATWMLESQL1.sal.co.at -SqlCredential $cred -ComputerName SVATGRAZSQL1.sal.co.at, SVATINZSQL1.sal.co.at, SVATUMKLSQL1.sal.co.at, SVATLEOGSQL1.sal.co.at, SVATSAWRSQL1.sal.co.at,SVATSCHISQL1.sal.co.at, SVSKSMSKSQL1.sal.co.at, SVATWMLESQL1.sal.co.at -Credential $cred -Checks FailedJob, LongRunningJob, AgentAlert, LastJobRunTime, SuspectPage, InvalidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, LastFullBackup, LastDiffBackup, LastLogBackup, CompatibilityLevel, DatabaseStatus, QueryStoreEnabled, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan, DiskAllocationUnit, SPN -PassThru | Convert-DbcResult -Label Production | Write-DbcTable -SqlInstance localhost -Database dbachecks

Write-Host "Checking test environment"
Invoke-DbcCheck -SqlInstance SVATSMWWD1.sal.co.at, SALSVATTSAMIG1.sal.co.at -SqlCredential $cred -ComputerName SVATSMWWD1.sal.co.at, SALSVATTSAMIG1.sal.co.at -Credential $cred -Checks FailedJob, LongRunningJob, AgentAlert, LastJobRunTime, SuspectPage, InvalidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, LastFullBackup, LastDiffBackup, LastLogBackup, CompatibilityLevel, DatabaseStatus, QueryStoreEnabled, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan, DiskAllocationUnit, SPN -PassThru | Convert-DbcResult -Label Test | Write-DbcTable -SqlInstance localhost -Database dbachecks

Write-Host "Checking clusters"
Invoke-DbcCheck -SqlInstance SQL1FCIHQ22.sal.co.at, SVATSMWSQLC1.sal.co.at, SQL1FCIEN.sal.co.at, SQL1FCIENCIT.sal.co.at -SqlCredential $cred -ComputerName SQL1FCIHQ22.sal.co.at, SVATSMWSQLC1.sal.co.at, SQL1FCIEN.sal.co.at, SQL1FCIENCIT.sal.co.at -Credential $cred -Checks FailedJob, LongRunningJob, AgentAlert, LastJobRunTime, SuspectPage, InvalidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, LastFullBackup, LastDiffBackup, LastLogBackup, CompatibilityLevel, DatabaseStatus, QueryStoreEnabled, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan, DiskAllocationUnit, SPN -PassThru | Convert-DbcResult -Label Cluster | Write-DbcTable -SqlInstance localhost -Database dbachecks

# Start-DbcPowerBi -FromDatabase