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
    Write-Host "Importing $($file.Name) into DataTable-Variable"
    $DataTable = Import-Csv $file.FullName -Delimiter ";"
    Write-DbaDbTableData -SqlInstance SQL1FCIHQ22.sal.co.at -InputObject $DataTable -Database AWSInvest -Table $tablename -AutoCreateTable
    Write-Host "File $($file.Name) processed"
    Move-Item $file.FullName .\done\
    Remove-Variable DataTable
}

<#
Spezielle CSV-Header - manuell ersetzen vor Import!

EKBE:
Einkaufsbeleg;Position;Laufende Kontierung;Vorgangsart;Materialbelegjahr;Materialbeleg;Materialbeleg_Position;Bestellentwicklungstyp;Bewegungsart;Buchungsdatum;Menge;Menge_BPR;Betrag_Hauswährung;Betrag;Währung;Ausgleichswert_HW;WESperrbestand_BME;WESperrbestand_BPME;SollHabenKZ;Bewertungsart;Endlieferung;Referenz;Geschäftsjahr_RefBeleg;Referenzbeleg;RefBeleg_Position;Grund_Bewegung;Erfassungsdatum;Erfassungsuhrzeit;Rechnungswert;Einhaltung_Versandvorschrift;Rechnungswert_FW;Material;Werk;WESt_trotz_RE;LfdNr;BelegkondNr;Steuerkennzeichen;Lieferscheinmenge;LieferscheinMngEinh;Material_2;Ausgleichswert_FW;Hauswährung;Menge_2;Charge;Belegdatum;Wertbildung_offen;Kontierung_Rechprüf_ungeplant;AnlageUser;Leistung;Paketnummer;Leistungszeile;LfdBestellkontierung;SrvRetourekennzeichen;Ausgleichswert_FW_2;RechnBetrag_FW;SAPRelease;Menge_3;MengeBPR;Betrag_Hauswährung_2;Betrag_2;Bewerteter_WESperrbst_BME;Bewerteter_WESperrbest_BPME;Abnahme_Lieferant;Ausgleichswert_HW_2;Kursdifferenzbetrag;Einbehalt_Belegwährung;Einbehalt_Buchungskreiswährung;Gebuchter_Einbehalt_Belegwährung;Gebuchter_Einbehalt_BW;Mehrfachkontierung;Währungskurs;Herkunft_Rechnungsposition;Lieferung;Position_2;Bestandssegment;Logisches_System;VAkEtmg;Knz_DIE_abgeschl;Saisonjahr;Saison;Kollektion;Thema;Merkmalsbezeichnung1;Merkmalsbezeichnung2;Merkmalsbezeichnung3

EKKO:
Einkaufsbeleg;Buchungskreis;Einkaufsbelegtyp;Einkaufsbelegart;Status;AnlageDatum;AnlageUser;Positionsintervall;LetztePosition;Lieferant;Zahlungsbedingung;Währung;Währungskurs;KursFixiert;Belegdatum;Laufzeitbeginn;Laufzeitende;Bewerbungsfrist;Angebotsfrist;Bindefrist;Angebot;Angebotsdatum;Rahmenvertrag;WENachricht;Incoterms;Incoterms2;BelegkonditionNr;Rechnungssteller;AußenhandelsdatenNr;KonditionenZeitabhängig;Adressnummer

EKPO:
Einkaufsbeleg;Position;Löschkennzeichen;LetzteÄnderung;Kurztext;Material;Material2;Buchungskreis;Werk;Lagerort;Warengruppe;Einkaufsinfosatz;Lieferantenmaterialnr;Zielmenge;Bestellmenge;Bestellmengeneinheit;BestellpreisME;Mengenumrechnung;Mengenumrechnung2;entspricht;Nenner;Bestellnettopreis;Preiseinheit;Bestellnettowert;Bruttobestellwert;Steuerkennzeichen;InfoUpdate;Anzahl_Mahnungen;Mahnung1;Mahnung2;Mahnung3;Tol_Überlieferung;Unbegrenzte_Überl;Tol_Unterlieferung;Bewertungsart;Bewertungstyp;Absagekennzeichen;Endlieferung;Endrechnung;Positionstyp;Kontierungstyp;Verbrauch;Verteilungskennz;Teilrechnung;Wareneingang;WEunbewertet;Rechnungseingang;Webez_RechnPrüfung;Bestätigungspflicht;Auftragsbestätigung;Rahmenvertrag;Pos_d_überg_Vertrags;Basismengeneinheit;Zielwert_Rahmenvertr;Nicht_abzugsfähig;Normalabrufmenge;Preisdatum;Einkaufsbelegtyp;Effektivwert;Obligorelevant;Kunde;Adresse;FortschreibGruppe;Planlieferzeit;Nettogewicht;Gewichtseinheit;EAN_UPC_Code;BestätigSteuerung;Bruttogewicht;Volumen;Volumeneinheit;Incoterms;Incoterms2;Bestellnettowert2;Statistisch;Lieferant;LBLieferant;Werksüberg_konf_Mat;Materialtyp;Adresse2;InterneObjektnummer;Bestellanforderung;BanfPosition;Materialart;Zwischensumme1;Zwischensumme2;Zwischensumme3;Naturalrabattfähig;Bonusbasis;Anforderer;Dispobereich;Bedarfsdringlichkeit;Bedarfspriorität;Anlegedatum;Anlegeuhrzeit;EinbehaltProzent;Anzahlung;Anzahlungsprozentsatz;Anzahlungsbetrag;Fälligkeitsdatum_Anzahlung;Reservierung;PosNr_UmlagReservierung;Pool_einzelcodiert_gestattet;Bestellposition_ID_Advantex

MSEG:
Materialbeleg;Materialbelegjahr;Materialbelegposition;Bewegungsart;Material;Werk;Lagerort;Charge;Lieferant;Kunde;Kundenauftrag;Kundenauftragposition;Kundenauftrag_Eint;KZSollHaben;Währung;BetragHauswährung;Bezugsnebenkosten;Betrag;Menge;BasisME;Menge_ErfassME;ErfassME;Menge_BPME;BPME;Bestellung;Bestellposition;RefBeleg_Geschäftsjahr;RefBeleg;RefBeleg_Position;MatBeleg_Jahr;MatBeleg;MatBeleg_Position;Endlieferung;Memotext;Warenempfänger;Abladestelle;Geschäftsbereich;PartnerGeschäftsbereich;Kostenstelle;Geschäftsjahr;RückbuchungErlaubt;RückbuchenVorjahr;Buchungskreis;Belegnummer;Belegposition;Belegnummer2;Belegpositon2;Reservierung;ReservierungPosition;Endausgefasst;Menge2;StatistikRelevant;MaterialEmfpänger;WerkEmpfänger;LagerortEmfpänger;Sachkonto;Menge_BestellME;BestellME;WESt_trotz_RE;Lieferant2;BetragExt_Hauswährung;VKWertBrutto;Aktion;LfdKontierung;Bestandsmaterial;EmpfMaterial;Mengenstring;Wertestring;Mengenfortschreibung;Wertfortschreibung;BestandBewertet;GesamtwertVorBuchung;Kundenauftrag2;Kundenauftrag2position;Vorgangsart;Buchungsdatum;Erfassungsdatum;Erfassungszeit;Benutzername;Referenz;Transaktionscode;Lieferung;LieferungPosition;Änderungsgrund;Branche
#>