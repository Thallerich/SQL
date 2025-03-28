<#
Convert Excel to CSV
#>

$excel = New-Object -ComObject Excel.Application
$excelfiles = @(Get-ChildItem -Path "C:\Users\thalst.SAL\Downloads\csv\" -Filter *.xlsx)
$processtype = ""
$currdate = (Get-Date).ToString("yyyy-MM-dd")
$counterBSEG = 1
$counterEKBE = 1
$counterEKKO = 1
$counterEKPO = 1
$counterMSEG = 1
$counterACDOCA = 1

foreach ($excelfile in $excelfiles)
{
    $processtype = ($excelfile.BaseName).SubString(0, ($excelfile.BaseName).IndexOf('_'))
    if ($processtype -eq "BSEG" -or $processtype -eq "EKBE" -or $processtype -eq "EKKO" -or $processtype -eq "EKPO" -or $processtype -eq "MSEG" -or $processtype -eq "ACDOCA")
    {
        if ($processtype -eq "BSEG") { $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + $processtype + "\" + $processtype + "_" + $currdate + "_" + $counterBSEG.ToString() + ".csv" }
        if ($processtype -eq "EKBE") { $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + $processtype + "\" + $processtype + "_" + $currdate + "_" + $counterEKBE.ToString() + ".csv" }
        if ($processtype -eq "EKKO") { $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + $processtype + "\" + $processtype + "_" + $currdate + "_" + $counterEKKO.ToString() + ".csv" }
        if ($processtype -eq "EKPO") { $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + $processtype + "\" + $processtype + "_" + $currdate + "_" + $counterEKPO.ToString() + ".csv" }
        if ($processtype -eq "MSEG") { $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + $processtype + "\" + $processtype + "_" + $currdate + "_" + $counterMSEG.ToString() + ".csv" }
        if ($processtype -eq "ACDOCA") { $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + $processtype + "\" + $processtype + "_" + $currdate + "_" + $counterACDOCA.ToString() + ".csv" }
        Write-Host "Converting $($excelfile.Name)"
        $workbook = $excel.Workbooks.Open($excelfile)
        $workbook.SaveAs($savepath, 62) <# Save as CSV-UTF8 (xlCSVUTF8) #>
        $workbook.Close($false)
        Move-Item $excelfile "C:\Users\thalst.SAL\Downloads\csv\_ExcelDone\"
        if ($processtype -eq "BSEG") { $counterBSEG++ }
        if ($processtype -eq "EKBE") { $counterEKBE++ }
        if ($processtype -eq "EKKO") { $counterEKKO++ }
        if ($processtype -eq "EKPO") { $counterEKPO++ }
        if ($processtype -eq "MSEG") { $counterMSEG++ }
        if ($processtype -eq "ACDOCA") { $counterACDOCA++ }
    }
}

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
Remove-Variable excel