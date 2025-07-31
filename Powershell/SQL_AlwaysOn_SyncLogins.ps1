Import-Module dbatools -MinimumVersion 2.5.1
Set-DbatoolsInsecureConnection -SessionOnly

$AGLSN = 'SQL1AG-01.sal.co.at'

$primaryReplica =    Get-DbaAgReplica -SqlInstance $AGLSN | Where-Object Role -eq Primary | Select-Object -First 1
$secondaryReplicas = Get-DbaAgReplica -SqlInstance $AGLSN | Where-Object Role -eq Secondary | Select-Object -First 1

$LoginsOnPrimary = (Get-DbaLogin -SqlInstance $primaryReplica.Name)

$secondaryReplicas | ForEach-Object {
    
    $LoginsOnSecondary = (Get-DbaLogin -SqlInstance $_.Name)

    $diff = $LoginsOnPrimary | Where-Object Name -notin ($LoginsOnSecondary.Name)
    if($diff) {
        Copy-DbaLogin -Source $primaryReplica.Name -Destination $_.Name -Login $diff.Nane
    }
    
    Sync-DbaLoginPermission -Source $primaryReplica.Name -Destination $_.Name
}