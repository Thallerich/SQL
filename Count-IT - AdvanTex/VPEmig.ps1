param (
    [switch]$IsLive
);

if ($IsLive) {
  $mandant = "Salesianer"
} else {
  $mandant = "Salesianer_Test"
}

Import-Module -Name dbatools
Set-DbatoolsInsecureConnection -SessionOnly

$step2file = Join-Path $PSScriptRoot "1_prep_worktable.sql"
$step3file = Join-Path $PSScriptRoot "2_process.sql"

Write-Host "Preparing work table on AdvanTex DB"
Invoke-DbaQuery -SqlInstance SALADVPSQLC1A1.salres.com -Database $mandant -File $step2file

Write-Host "Get VPE from Count-IT and export to csv-file"
Copy-DbaDbTableData -SqlInstance SQL1FCIENCIT.sal.co.at -Database CustomerSystem -Table "[dbo].[PackageUnit]" -Query "SELECT PackageUnit.PackageUnitID, PackageUnit.CreationDate, PackageUnit.LocationID, PackageUnit.EanPackagingUnit AS Menge, Chip.Sgtin96HexCode, Chip.ArticleID FROM CustomerSystem.dbo.PackageUnit JOIN CustomerSystem.dbo.Chip ON Chip.PackageUnitID = PackageUnit.PackageUnitID WHERE PackageUnit.CreationDate > N'2024-01-01 00:00:00.000';" -Destination SALADVPSQLC1A1.salres.com -DestinationDatabase $mandant -DestinationTable "_PackageUnitCIT"

Write-Host "Processing VPE data in AdvanTex DB"
Invoke-DbaQuery -SqlInstance SALADVPSQLC1A1.salres.com -Database $mandant -File $step3file -NoExec

Write-Host "Cleaning up"
# Invoke-Sqlcmd -Query "DROP TABLE _PackageUnitCIT" -ServerInstance SALADVPSQLC1A1.salres.com -Database $mandant

Write-Host "All done!"