# Script to remotely start a scheduled task
# Author: Stefan THALLER
# Version: 0.1
# Timestamp: 2025-06-12 11:46

# Script to create encrypted credential XML in the current location of this script - comment out everything else and uncomment the following block
# Resulting file is not portable as it is encrypted for the user and machine that created it

<# 

$cred = Get-Credential
Export-CliXml -InputObject $cred -Path "$PSScriptRoot\SDCEncryptedCredential.xml"

#>

$remoteserver = "SRVATENSDC01.sal.co.at"
$credxml = "$PSScriptRoot\SDCEncryptedCredential.xml"
$rmtcred = Import-CliXml -Path $credxml
$rmtsession = New-CimSession -ComputerName $remoteserver -Credential $rmtcred

#Start-ScheduledTask -TaskPath "" -TaskName "" -CimSession $rmtsession

#debug only
Get-ScheduledTask -TaskPath "\AdvanTex\" -CimSession $rmtsession