Import-Module BitsTransfer

# Specifiy backup paths (and servers) here
$source = @(
  @{location = 'Graz'; path = '\\SVATGRAZSQL1.sal.co.at\M$\Backup\SVATGRAZSQL1$SQL1\Salesianer_Graz\FULL\'},
  @{location = 'SA22'; path = '\\SVATSMWFP1.sal.co.at\SQL-Backups\SQL1FCIHQ22$SQL1\Salesianer_SA22\FULL\'},
  @{location = 'Inzing'; path = '\\SVATINZSQL1.sal.co.at\m$\BACKUP\SVATINZSQL1$SQL1\Salesianer_Inzing\FULL'},
  @{location = 'Klagenfurt'; path = '\\SVATUMKLSQL1.sal.co.at\M$\Backup\SVATUMKLSQL1$SQL1\Salesianer_Klagenfurt\FULL\'},
  @{location = 'Wr. Neustadt'; path = '\\SVATSAWRSQL1.sal.co.at\M$\Backup\SVATSAWRSQL1$SQL1\Salesianer_SAWR\FULL\'},
  @{location = 'Bratislava'; path = '\\SVSKSMSKSQL1.sal.co.at\M$\Backup\SVSKSMSKSQL1$SQL1\Salesianer_SMSK\FULL\'},
  @{location = 'Enns 1'; path = '\\SRVATENHVREP01.sal.co.at\SQLBackup\SQL1FCIEN$SQL1\Salesianer_Enns_1\FULL\'},
  @{location = 'Enns 2'; path = '\\SRVATENHVREP01.sal.co.at\SQLBackup\SQL1FCIEN$SQL1\Salesianer_Enns_2\FULL\'},
  @{location = 'Lenzing 1'; path = '\\SVATWMLESQL1.sal.co.at\M$\Backup\svatwmlesql1$SQL1\Salesianer_Lenzing_1\FULL\'},
  @{location = 'Lenzing 2'; path = '\\SVATWMLESQL1.sal.co.at\M$\Backup\svatwmlesql1$SQL1\Salesianer_Lenzing_2\FULL\'}
)

# specificy destination directory where backups will be gathered
$dest = 'C:\Users\thalst.SAL\Downloads\Mandanten\'

# make sure there is no drive T as we will be using that
if ((Test-Path -PathType Container -Path "T:"))
{
  Write-Host "ERROR: There is already a mapped drive T:"
  exit
}

# get credential to use for all servers
$cred = Get-Credential -Message "Please input domain admin credentials:"

# create destination directory if it does not exists
if (!(Test-Path -PathType Container $dest)) {
    New-Item -ItemType Directory -Path $dest
}

# mapping drives with credentials and copying to destination

foreach ($src in $source)
{
  $location = $src.location;
  $srcpath = $src.path;

  if (($location -like "Enns ?") -or ($location -like "Lenzing ?") -or ($location -eq "SA22"))
  {
    $null = New-PSDrive -Name T -PSProvider FileSystem -Root $srcpath
  }
  else
  {
    $null = New-PSDrive -Name T -PSProvider FileSystem -Root $srcpath -Credential $cred
  }

  if ((Test-Path -PathType Container $srcpath))
  {
    $lastbackupfile = Get-ChildItem -Path "T:" -Filter *.bak | Sort-Object LastWriteTime | Select-Object -Last 1

    $destfile = $dest + $lastbackupfile.Name
    if (-not (Test-Path $destfile))
    {
      Start-BitsTransfer -Source $lastbackupfile -Destination $dest -Description $location -DisplayName "Mandant"
    }
    else
    {
      Write-Host "$location has already been copied to $dest"
    }
  }
  else
  {
    Write-Host "Could not connect to backup directory!"
  }
  Remove-PSDrive -Name T
}