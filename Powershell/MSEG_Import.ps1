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

Import-Module dbatools;

Set-DbaToolsInsecureConnection -SessionOnly

Set-Location '.\Downloads\EKBE\Split\'

$infiles = @(Get-ChildItem -Filter EKBESplit*.csv)

foreach ($file in $infiles) {
    $DataTable = Import-Csv $file.FullName -Delimiter ";"
    Write-DbaDbTableData -SqlInstance SQL1FCIHQ22.sal.co.at -InputObject $DataTable -Database AWSInvest -Table AWSInvest.dbo.EKBE_Import -AutoCreateTable
    Write-Host "File $($file.Name) processed"
    Move-Item $file.FullName .\done\
    Remove-Variable DataTable
    [GC]::Collect()
}

# Final MSEG-Table for SQL

<#

DROP TABLE IF EXISTS MSEG;
GO

CREATE TABLE MSEG (
  ID int IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
  Materialbeleg char(15),
  Materialbelegjahr smallint,
  Materialbelegposition smallint,
  Bewegungsart smallint,
  Material nchar(15),
  Werk char(4),
  Lagerort char(4),
  Charge char(1),
  Lieferant int,
  Kunde int,
  Kundenauftrag char(15),
  Kundenauftragposition smallint,
  Kundenauftrag_Eint tinyint,
  KZSollHaben char(1),
  Währung char(3),
  BetragHauswährung money,
  Bezugsnebenkosten money,
  Betrag money,
  Menge int,
  BasisME char(3),
  Menge_ErfassME int,
  ErfassME char(3),
  Menge_BPME int,
  BPME char(3),
  Bestellung bigint,
  Bestellposition int,
  RefBeleg_Geschäftsjahr smallint,
  RefBeleg bigint,
  RefBeleg_Position smallint,
  MatBeleg_Jahr smallint,
  MatBeleg bigint,
  MatBeleg_Position smallint,
  Endlieferung char(1),
  Memotext nvarchar(max),
  Warenempfänger char(15),
  Abladestelle char(20),
  Geschäftsbereich char(4),
  PartnerGeschäftsbereich char(4),
  Kostenstelle char(15),
  Geschäftsjahr smallint,
  RückbuchungErlaubt bit,
  RückbuchenVorjahr int,
  Buchungskreis smallint,
  Belegnummer bigint,
  Belegposition smallint,
  Belegnummer2 bigint,
  Belegpositon2 smallint,
  Reservierung bigint,
  ReservierungPosition smallint,
  Endausgefasst bit,
  Menge2 int,
  StatistikRelevant tinyint,
  MaterialEmfpänger nchar(15),
  WerkEmpfänger char(4),
  LagerortEmfpänger char(4),
  Sachkonto int,
  Menge_BestellME int,
  BestellME char(3),
  WESt_trotz_RE char(1),
  Lieferant2 int,
  BetragExt_Hauswährung money,
  VKWertBrutto money,
  Aktion char(1),
  LfdKontierung bit,
  Bestandsmaterial nchar(15),
  EmpfMaterial nchar(15),
  Mengenstring char(4),
  Wertestring char(4),
  Mengenfortschreibung char(1),
  Wertfortschreibung char(1),
  BestandBewertet int,
  GesamtwertVorBuchung money,
  Kundenauftrag2 char(15),
  Kundenauftrag2position smallint,
  Vorgangsart char(2),
  Buchungsdatum date,
  Erfassungsdatum date,
  Erfassungszeit time,
  Benutzername char(15),
  Referenz char(15),
  Transaktionscode char(4),
  Lieferung bigint,
  LieferungPosition smallint,
  Änderungsgrund char(10),
  Branche char(4)
);

GO

#>