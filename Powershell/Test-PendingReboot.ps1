# PowerShell
function Test-PendingReboot
{
  $svc  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\" `
        + "Component Based Servicing\RebootPending";

  $wupd = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\" `
        + "WindowsUpdate\Auto Update\RebootRequired"

  $file = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager";

  $reasons = 0;

  if (Get-ChildItem $svc -EA Ignore) 
  { $reasons += 1; }

  if (Get-Item $wupd -EA Ignore) 
  { $reasons += 2; }

  if (Get-ItemProperty $file -Name PendingFileRenameOperations -EA Ignore) 
  { $reasons += 4; }

  try 
  { 
    $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
    $status = $util.DetermineIfRebootPending()
    if(($null -ne $status) -and $status.RebootPending)
    {
      $reasons += 8;
    }
  }catch{}

  return $reasons;
}

Test-PendingReboot;