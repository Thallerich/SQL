$src = "\\atenadvantex01.wozabal.int\AdvanTex\Data\Export\WienIT\AdvantexPDF\"
$conv = "\\atenadvantex01.wozabal.int\AdvanTex\Data\Export\WienIT\GSPDF\"
$proczip = "\\atenadvantex01.wozabal.int\AdvanTex\Data\Export\WienIT\zip\"
$ftpdone = "\\atenadvantex01.wozabal.int\AdvanTex\Data\Export\WienIT\zip\sent\"

$gspath = "'C:\Program Files\gs\gs9.27\bin\gswin64c.exe'"
$7zpath = "'C:\Program Files\7-Zip\7z.exe'"

Get-ChildItem -Path "$($src)*.pdf" | ForEach-Object {
    $filename = $_.Name
    Invoke-Expression("& $($gspath) -sDEVICE=pdfwrite -dCompatibilityLevel=`"1.4`" -o `"$($conv)$($filename)`" `"$($src)$($filename)`"")
    Remove-Item -Path "$($src)$($filename)"
}

If(Test-Path -Path ("$($src)*.txt")) {
    Move-Item -Path "$($src)*.txt" -Destination "$($conv)" -Force
}

If(Test-Path -Path ("$($conv)*.pdf")) {
    Invoke-Expression("& $($7zpath) a -tzip `"$($proczip)$(Get-Date -f yyyyMMddHHmmss)_invoice.zip`" `"$($conv)*.pdf`" `"$($conv)*.txt`"")
    Remove-Item "$($conv)*.pdf"
    Remove-Item "$($conv)*.txt"

    Write-Output $(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") *>> \\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\wienit_upload.log
    \\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\WinSCP\winscp.com /script=\\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\wienit_upload.sftp *>> \\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\wienit_upload.log
    Write-Output ""  *>> \\atenadvantex01\advantex\data\EDI\upload.log
    Move-Item -Path "$($proczip)*.zip" -Destination "$($ftpdone)" -Force
}

## Run again vor "E-Mail-Versand + Papierdruck"
Start-Sleep -Seconds 5  ## Wait 5 Seconds before running again

Get-ChildItem -Path "$($src)\EuP\*.pdf" | ForEach-Object {
    $filename = $_.Name
    Invoke-Expression("& $($gspath) -sDEVICE=pdfwrite -dCompatibilityLevel=`"1.4`" -o `"$($conv)$($filename)`" `"$($src)\EuP\$($filename)`"")
    Remove-Item -Path "$($src)\EuP\$($filename)"
}

If(Test-Path -Path ("$($src)\EuP\*.txt")) {
    Move-Item -Path "$($src)\EuP\*.txt" -Destination "$($conv)" -Force
}

If(Test-Path -Path ("$($conv)*.pdf")) {
    Invoke-Expression("& $($7zpath) a -tzip `"$($proczip)$(Get-Date -f yyyyMMddHHmmss)_invoice.zip`" `"$($conv)*.pdf`" `"$($conv)*.txt`"")
    Remove-Item "$($conv)*.pdf"
    Remove-Item "$($conv)*.txt"

    Write-Output $(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") *>> \\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\wienit_upload.log
    \\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\WinSCP\winscp.com /script=\\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\wienit_upload.sftp *>> \\atenadvantex01.wozabal.int\AdvanTex\Data\scripts\wienit_upload.log
    Write-Output ""  *>> \\atenadvantex01\advantex\data\EDI\upload.log
    Move-Item -Path "$($proczip)*.zip" -Destination "$($ftpdone)" -Force
}