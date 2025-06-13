$taskname = 'AdvanTex - UHF Service Driver App'
$taskpath = '\AdvanTex\'

$task = Get-ScheduledTask -TaskName $taskname
$settings = $task.Settings
$settings.Priority = 4  # Normal priority - for possible values check: https://learn.microsoft.com/en-us/windows/win32/taskschd/tasksettings-priority#remarks
Set-ScheduledTask -TaskName $taskName -TaskPath $taskpath -Settings $settings