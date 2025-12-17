# Script to remotely start a scheduled task
# Author: Stefan THALLER
# Version: 1.1
# Timestamp: 2025-12-05 07:52

# Script to create encrypted credential file in the current location of this script - comment out everything else and uncomment the following block

<#
Function Save-Credential([string]$UserName, [string]$KeyPath) {
   If (!(Test-Path $KeyPath)) {
       Try {
           New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP | Out-Null
       }
       Catch {
           Throw $_.Exception.Message
       }
   }
   $Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
   $Credential.Password | ConvertFrom-SecureString | Out-File "$($KeyPath)\SDCAdmin.cred" -Force
}

Save-Credential -UserName "sal\AdvantexAdmin" -KeyPath "$PSScriptRoot"
#>

Clear-Host

$remoteserver = "SRVATLESDC01.sal.co.at"
$username = "sal\AdvantexAdmin"
$pwdsecurestring = Get-Content "$PSScriptRoot\SDCAdmin.cred" | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $pwdsecurestring
$rmtsession = New-CimSession -ComputerName $remoteserver -Credential $cred
$errormsg = ""

$selection = Read-Host -Prompt "Welcher SDC-Gateway soll neu gestartet werden? (Zahl in eckiger Klammer eingeben)`nMetrik 1 [1]  Metrik 2 [2]  Beide [0]"

switch($selection) {
  "0" { Start-ScheduledTask -TaskPath "\AdvanTex\" -TaskName "SDC Gateways remote restart" -CimSession $rmtsession -ErrorAction SilentlyContinue -ErrorVariable errormsg }
  "1" { Start-ScheduledTask -TaskPath "\AdvanTex\" -TaskName "SDC Gateway Lenzing 1" -CimSession $rmtsession -ErrorAction SilentlyContinue -ErrorVariable errormsg }
  "2" { Start-ScheduledTask -TaskPath "\AdvanTex\" -TaskName "SDC Gateway Lenzing 2" -CimSession $rmtsession -ErrorAction SilentlyContinue -ErrorVariable errormsg }
  default {
    Write-Host "Ungültige Eingabe!"
    Exit
  }
}

switch($selection) {
  "0" { $Body = "The user $env:USERNAME has executed the remote restart script for SDC Gateways in Lenzing!" }
  "1" { $Body = "The user $env:USERNAME has executed the remote restart script for SDC Gateway for Metrik 1 in Lenzing!" }
  "2" { $Body = "The user $env:USERNAME has executed the remote restart script for SDC Gateway for Metrik 2 in Lenzing!" }
}

if ($errormsg -eq "") {
  $mailnotification = @{
      From = 'SDC Restart Script <no-reply@salesianer.com>'
      To = 'Stefan THALLER <s.thaller@salesianer.com>'
      Subject = 'SDC Gateways restart script - Lenzing'
      Body = $Body
      SmtpServer = 'SMWMAIL2.sal.co.at'
  }

  switch($selection) {
    "0" { Write-Host "Neustart für die SDC Gateways für Metrik 1 und Metrik 2 wurde erfolgreich ausgelöst!" -ForegroundColor Green }
    "1" { Write-Host "Neustart für die SDC Gateways für Metrik 1 wurde erfolgreich ausgelöst!" -ForegroundColor Green }
    "2" { Write-Host "Neustart für die SDC Gateways für Metrik 2 wurde erfolgreich ausgelöst!" -ForegroundColor Green }
  }
  Write-Host "Bitte 5 Minuten warten, bis der Neustart abgeschlossen ist!" -ForegroundColor Yellow
}
else {
  $mailnotification = @{
      From = 'SDC Restart Script <no-reply@salesianer.com>'
      To = 'Stefan THALLER <s.thaller@salesianer.com>'
      Subject = 'ERROR: SDC Gateways restart script - Lenzing'
      Body = "The user $env:USERNAME has encountered an error while executing the remote restart script for SDC Gateways in Lenzing! Error message is: $errormsg"
      SmtpServer = 'SMWMAIL2.sal.co.at'
  }

  switch($selection) {
    "0" { Write-Host "Fehler beim Auslösen des Neustarts der SDC Gateways für Metrik 1 und Metrik 2!" -ForegroundColor Red }
    "1" { Write-Host "Fehler beim Auslösen des Neustarts der SDC Gateways für Metrik 1!" -ForegroundColor Green }
    "2" { Write-Host "Fehler beim Auslösen des Neustarts der SDC Gateways für Metrik 2!" -ForegroundColor Green }
  }
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