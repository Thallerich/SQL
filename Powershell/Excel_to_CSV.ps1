<#
Convert Excel to CSV
#>

$excel = New-Object -ComObject Excel.Application
$excelfiles = @(Get-ChildItem -Path "C:\Users\thalst.SAL\Downloads\csv\" -Filter *.xlsx)
$counter = 1

foreach ($excelfile in $excelfiles) {
    
    $savepath = "C:\Users\thalst.SAL\Downloads\csv\" + ($excelfile.BaseName).SubString(0, 4) + "\" + ($excelfile.BaseName).SubString(0, 4) + $counter.ToString() + ".csv"
    Write-Host "Converting $($excelfile.Name)"
    $workbook = $excel.Workbooks.Open($excelfile)
    $workbook.SaveAs($savepath, 62) <# Save as CSV-UTF8 (xlCSVUTF8) #>
    $workbook.Close($false)
    Move-Item $excelfile "C:\Users\thalst.SAL\Downloads\csv\_ExcelDone\"
    $counter++
}

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
Remove-Variable excel