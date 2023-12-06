# To-Do: Use \\svatsmwfp1.sal.co.at\sql-backups instead - should have better bandwith to HQ22 

Import-Module dbatools
Set-DbaToolsInsecureConnection -SessionOnly

Write-Host "Starting Backup for GRAZ"
Backup-DbaDatabase -SqlInstance SVATGRAZSQL1.sal.co.at -Database Salesianer_Graz -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for INZING"
Backup-DbaDatabase -SqlInstance SVATINZSQL1.sal.co.at -Database Salesianer_Inzing -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for KLAGENFURT"
Backup-DbaDatabase -SqlInstance SVATUMKLSQL1.sal.co.at -Database Salesianer_Klagenfurt -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for WR. NEUSTADT"
Backup-DbaDatabase -SqlInstance SVATSAWRSQL1.sal.co.at -Database Salesianer_SAWR -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for BRATISLAVA"
Backup-DbaDatabase -SqlInstance SVSKSMSKSQL1.sal.co.at -Database Salesianer_SMSK -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for LENZING"
# Backup-DbaDatabase -SqlInstance SVATWMLESQL1.sal.co.at -Database Salesianer_Lenzing1 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName
# Backup-DbaDatabase -SqlInstance SVATWMLESQL1.sal.co.at -Database Salesianer_Lenzing2 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for ENNS"
Backup-DbaDatabase -SqlInstance SQL1FCIEN.sal.co.at -Database Salesianer_Enns_1 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName
Backup-DbaDatabase -SqlInstance SQL1FCIEN.sal.co.at -Database Salesianer_Enns_2 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Backup-DbaDatabase -SqlInstance SQL1FCIEN.sal.co.at -Database Wozabal_Lenzing_1 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName
Backup-DbaDatabase -SqlInstance SQL1FCIEN.sal.co.at -Database Wozabal_Lenzing_2 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for HQ22"
Backup-DbaDatabase -SqlInstance SQL1FCIHQ22.sal.co.at -Database Salesianer_SA22 -CopyOnly -Type Full -CompressBackup -Checksum -Path \\srvatenhvrep01.sal.co.at\SQLBackup\Mandanten -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "Starting Backup for TSA RZ"
# Salesianer-Backup is typically not needed as there should be a Salesianer.bak file from the nightly database copy job
# Backup-DbaDatabase -SqlInstance SALADVPSQLC1A1.salres.com -Database Salesianer -CopyOnly -Type Full -CompressBackup -Checksum -Path \\salshdsvm09_681.salres.com\mssql_backup\_temp -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName
Backup-DbaDatabase -SqlInstance SALADVPSQLC1A1.salres.com -Database OWS -CopyOnly -Type Full -CompressBackup -Checksum -Path \\salshdsvm09_681.salres.com\mssql_backup\_temp -FilePath dbname_timestamp_backuptype_COPYONLY.bak -ReplaceInName

Write-Host "ALL BACKUPS completed!"

Write-Host "Now gathering backups"
<# TODO: copy backups somewhere #>
Write-Host "Done gathering backups - ALL DONE"