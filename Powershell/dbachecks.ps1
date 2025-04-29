Import-Module dbachecks;
Set-DbatoolsInsecureConnection -SessionOnly

$sqlcred = Get-Credential -UserName "sal\thalst" -Message "Please enter user password for sql server login: "
$dacred = Get-Credential -Username "sal\thalstadm" -Message "Please enter domain admin password for computer access: "

Write-Host "Checking production environment"
Invoke-DbcCheck -SqlInstance SVATGRAZSQL1.sal.co.at, SVATINZSQL1.sal.co.at, SVATUMKLSQL1.sal.co.at, SVATLEOGSQL1.sal.co.at, SVATSAWRSQL1.sal.co.at,SVATSCHISQL1.sal.co.at, SVSKSMSKSQL1.sal.co.at, SVATWMLESQL1.sal.co.at -SqlCredential $sqlcred -ComputerName SVATGRAZSQL1.sal.co.at, SVATINZSQL1.sal.co.at, SVATUMKLSQL1.sal.co.at, SVATLEOGSQL1.sal.co.at, SVATSAWRSQL1.sal.co.at,SVATSCHISQL1.sal.co.at, SVSKSMSKSQL1.sal.co.at, SVATWMLESQL1.sal.co.at -Credential $dacred -Checks FailedJob, LongRunningJob, AgentAlert, SuspectPage, ValidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, LastFullBackup, LastDiffBackup, LastLogBackup, CompatibilityLevel, DatabaseStatus, QueryStoreEnabled, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan, SPN -PassThru | Convert-DbcResult -Label Production | Write-DbcTable -SqlInstance localhost -Database dbachecks

Write-Host "Checking test environment"
Invoke-DbcCheck -SqlInstance SVATSMWWD1.sal.co.at, SALSVATTSAMIG1.sal.co.at -SqlCredential $sqlcred -ComputerName SVATSMWWD1.sal.co.at, SALSVATTSAMIG1.sal.co.at -Credential $dacred -Checks FailedJob, LongRunningJob, AgentAlert, SuspectPage, ValidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, CompatibilityLevel, DatabaseStatus, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan -PassThru | Convert-DbcResult -Label Test | Write-DbcTable -SqlInstance localhost -Database dbachecks

Write-Host "Checking clusters"
Invoke-DbcCheck -SqlInstance SQL1FCIHQ22.sal.co.at, SVATSMWSQLC1.sal.co.at, SQL1FCIEN.sal.co.at, SQL1FCIENCIT.sal.co.at -SqlCredential $sqlcred -ComputerName SQL1FCIHQ22.sal.co.at, SVATSMWSQLC1.sal.co.at, SQL1FCIEN.sal.co.at, SQL1FCIENCIT.sal.co.at -Credential $dacred -Checks FailedJob, LongRunningJob, AgentAlert, SuspectPage, ValidDatabaseOwner, LastGoodCheckDb, RecoveryModel, DatabaseGrowthEvent, LastFullBackup, LastDiffBackup, LastLogBackup, CompatibilityLevel, DatabaseStatus, QueryStoreEnabled, TempDbConfiguration, BackupPathAccess, DAC, MaxMemory, SupportedBuild, WhoIsActiveInstalled, LatestBuild, OlaInstalled, PowerPlan, SPN -PassThru | Convert-DbcResult -Label Cluster | Write-DbcTable -SqlInstance localhost -Database dbachecks

# Start-DbcPowerBi -FromDatabase