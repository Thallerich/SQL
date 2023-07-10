# Requires the SQLServer Module
# Install with the following command if missing
# Install-Module SQLServer -Scope AllUsers

# Import SQLServer Module if not loaded
if(@(Get-Module SQLServer).Length -eq 0)
{
    Import-Module SQLServer
}

# Set Directory to current script file location
$ScriptDirectory = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Set-Location $ScriptDirectory

# Load encrypted credentials
$User = "job_u4ber_copy"
$PasswordFile = ".\Encrypted_u4ber_Password.txt"
$KeyFile = ".\AES.key"
$key = Get-Content $KeyFile
$SQLCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)

# Execute Backup command
Invoke-Sqlcmd -InputFile ".\job_copytotest.sql" -ServerInstance "SMBDB1.sal.co.at\EXPRESS" -Credential $SQLCredential -Encrypt Optional