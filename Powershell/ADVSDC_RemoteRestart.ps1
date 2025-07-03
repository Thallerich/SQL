# Script to remotely start a scheduled task
# Author: Stefan THALLER
# Version: 1.0
# Timestamp: 2025-07-03 15:35

# Script to create encrypted credential XML in the current location of this script - comment out everything else and uncomment the following block
# Resulting file is not portable as it is encrypted for the user and machine that created it

<#
$cred = Get-Credential
Export-CliXml -InputObject $cred -Path "$PSScriptRoot\SDCEncryptedCredential.xml"
#>

Clear-Host

$remoteserver = "SRVATENSDC01.sal.co.at"
$credxml = "$PSScriptRoot\SDCEncryptedCredential.xml"
$rmtcred = Import-CliXml -Path $credxml
$rmtsession = New-CimSession -ComputerName $remoteserver -Credential $rmtcred
$errormsg = ""

Start-ScheduledTask -TaskPath "\AdvanTex\" -TaskName "SDC Gateways remote restart" -CimSession $rmtsession -ErrorAction SilentlyContinue -ErrorVariable errormsg

if ($errormsg -eq "") {
  $mailnotification = @{
      From = 'SDC Restart Script <no-reply@salesianer.com>'
      To = 'Stefan THALLER <s.thaller@salesianer.com>'
      Subject = 'SDC Gateways restart script - ENNS'
      Body = "The user $env:USERNAME has executed the remote restart script for SDC Gateways in Enns!"
      SmtpServer = 'SMWMAIL2.sal.co.at'
  }

  Write-Host "Neustart für die SDC Gateways für Metrik 1 und Metrik 3 wurde erfolgreich ausgelöst!" -ForegroundColor Green
  Write-Host "Bitte 5 Minuten warten, bis der Neustart abgeschlossen ist!" -ForegroundColor Yellow
}
else {
  $mailnotification = @{
      From = 'SDC Restart Script <no-reply@salesianer.com>'
      To = 'Stefan THALLER <s.thaller@salesianer.com>'
      Subject = 'ERROR: SDC Gateways restart script - ENNS'
      Body = "The user $env:USERNAME has encountered an error while executing the remote restart script for SDC Gateways in Enns! Error message is: $errormsg"
      SmtpServer = 'SMWMAIL2.sal.co.at'
  }

  Write-Host "Fehler beim Auslösen des Neustarts der SDC Gateways für Metrik 1 und Metrik 3!" -ForegroundColor Red
  Write-Host "Bitte die IT-Abteilung kontaktieren!" -ForegroundColor Red
}

Send-MailMessage @mailnotification -WarningAction SilentlyContinue

if ($errormsg -eq "") {
  # Define the total duration in seconds
  $duration = 300

  # Loop to simulate progress
  for ($i = 1; $i -le $duration; $i++) {
      # Calculate the percentage completed
      $percentComplete = ($i / $duration) * 100

      # Display the progress bar
      Write-Progress -Activity "Warte für 300 Sekunden (5 Minuten)..." -Status "$i Sekunden vergangen" -PercentComplete $percentComplete

      # Wait for 1 second
      Start-Sleep -Seconds 1
  }
}

Write-Host "Skript abgeschlossen!" -ForegroundColor Green