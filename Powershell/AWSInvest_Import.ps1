# Use this to split a csv file!

<#
function Split-Content {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String]$Path,
        [ULong]$HeadSize,
        [ValidateRange(1, [ULong]::MaxValue)][ULong]$DataSize = [ULong]::MaxValue,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]$Value
    )
    begin {
        $Header = [Collections.Generic.List[String]]::new()
        $DataCount = 0
        $PartNr = 1
    }
    Process {
        $ReadCount = 0
        while ($ReadCount -lt @($_).Count -and $Header.Count -lt $HeadSize) {
            if (@($_)[$ReadCount]) { $Header.Add(@($_)[$ReadCount]) }
            $ReadCount++
        }
        if ($ReadCount -lt @($_).Count -and $Header.Count -ge $HeadSize) {
            do {
                if ($DataCount -le 0) { # Should never be less
                    $FileInfo = [System.IO.FileInfo]$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
                    $FileName = $FileInfo.BaseName + $PartNr++ + $FileInfo.Extension
                    $LiteralPath = [System.IO.Path]::Combine($FileInfo.DirectoryName, $FileName)
                    $steppablePipeline = { Set-Content -LiteralPath $LiteralPath }.GetSteppablePipeline()
                    $steppablePipeline.Begin($PSCmdlet)
                    $steppablePipeline.Process($Header)
                }
                $Next = [math]::min(($DataSize - $DataCount), @($_).Count)
                if ($Next -gt $ReadCount) { $steppablePipeline.Process(@($_)[$ReadCount..($Next - 1)]) }
                $DataCount = ($DataCount + $Next - $ReadCount) % $DataSize
                if ($DataCount -le 0) { $steppablePipeline.End() }
                $ReadCount = $Next % @($_).Count
            } while ($ReadCount)
        }
    }
    End {
        if ($steppablePipeline) { $steppablePipeline.End() }
    }
}
#>

# Get-Content -ReadCount 1000 .\MSEG.csv | Split-Content -Path .\MSEGSplit.csv -HeadSize 1 -DataSize 100000

$processtype = "EKKO"

Clear-Host
Import-Module dbatools;

Set-DbaToolsInsecureConnection -SessionOnly

Set-Location "C:\Users\thalst.SAL\Downloads\csv\$processtype\"

$infiles = Get-ChildItem -Filter *.csv
$tablename = "AWSInvest.dbo." + $processtype + "_Import"

Remove-DbaDbTable -SqlInstance SQL1FCIHQ22.sal.co.at -Table $tablename -Confirm:$false

foreach ($file in $infiles) {
    $DataTable = Import-Csv $file.FullName -Delimiter ";"
    Write-DbaDbTableData -SqlInstance SQL1FCIHQ22.sal.co.at -InputObject $DataTable -Database AWSInvest -Table $tablename -AutoCreateTable
    Write-Host "File $($file.Name) processed"
    Move-Item $file.FullName .\done\
    Remove-Variable DataTable
}