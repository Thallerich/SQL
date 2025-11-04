Get-InstalledModule | ForEach-Object {
  $moduleName = $_.Name
  $currentVersion = [Version]$_.Version

  if ($moduleName -ne "Pester")  # Exclude Pester as older version is needed for dbachecks
  {
    Get-Module -Name $moduleName -ListAvailable | ForEach-Object {
      $oldVersion = [Version]$_.Version
      if ($oldVersion -lt $currentVersion) {
        Write-Host "Found old version $modulename [$oldVersion] - current version is $currentVersion - uninstalling"

        # Uninstall outdated version
        Write-Host "Uninstall-Module -Name $moduleName -RequiredVersion $oldVersion -Force"
      }
    }
  }
}