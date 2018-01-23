--------------------------------------------------------------------
-- Firma: Wozabal Textile Logistik
-- Übergabe der Rechnungen an die Fibu; 05.01.2016 GH
-- KopfPos = 'K' wird ignoriert, nur 'P' und 'S' werden verarbeitet
--           'P' = Position je Erlöskonto
--           'S' = Position je Kostenstelle, Kostenträger
--------------------------------------------------------------------

-- Skonto2 ist nicht in #bookingexport (ich benenne die Felder mit 'W' am Anfang, falls in einem neuen Rel. Skonto2 aufgenommen wird).:
IF object_id('tempdb..#be2') IS NOT NULL
BEGIN
  drop table #be2;
END

select *
into #be2
from #bookingexport;

alter table #be2 add Wnettotage integer;
alter table #be2 add Wskontotage1 integer;
alter table #be2 add Wskonto1 float;
alter table #be2 add Wskontotage2 integer;
alter table #be2 add Wskonto2 float;
alter table #be2 add UstIdNr char(15);

update be2 set WnettoTage = ZahlZiel.NettoTage, Wskonto1 = ZahlZiel.Skonto, Wskonto2 = ZahlZiel.Skonto2, WskontoTage1 = ZahlZiel.SkontoTage, WskontoTage2 = ZahlZiel.SkontoTage2
from RechKo, ZahlZiel, #be2 AS be2
where be2.BelegNr = RechKo.RechNr
  and RechKo.ZahlZielId = ZahlZiel.Id;

update be2 set UstIdNr = Kunden.UstIdNr
from RechKo, Kunden, #be2 AS be2
where be2.BelegNr = RechKo.RechNr
  and RechKo.KundenID = Kunden.ID;

select
 iif (KopfPos='P', '0', '1') as satzart,                                                -- Satzart 0 = Fibu-Daten, 1=Kostenrechnungsdaten
 iif (KopfPos='P', cast(Debitor as char(12)), null) as konto,                           -- Debitoren_Nr
 iif (KopfPos='P', right('00000000' + rtrim(GegenKonto),8), null) as gkonto,               -- Gegenkonto
 iif (KopfPos='P', UstIdNr, null) as uidnr,
 iif (KopfPos='P', cast(BelegNr as char(10)), null) as belegnr,                         -- BelegNr
 iif (KopfPos='P', BelegDat_, null) as buchdatum,                                         -- Belegdatum
 iif (KopfPos='P', BelegDat_, null) as belegdatum,                                        -- Belegdatum
 iif (KopfPos='P', '1', null) as buchcode,                                                 -- Buchungscode
 iif (KopfPos='P', left(WaeCode,3), null) as waehrung,
 iif (KopfPos='P', iif(left(WaeCode,3) = 'EUR', iif(bruttowert>=0, '+', '-') +
                   right('00000000000000' +
                   rtrim(cast(abs(Bruttowert) as varchar(15))),12),null),
                   null) as betrag,                                                     -- Brutto-Betrag
 iif (KopfPos='P', iif(left(WaeCode,3) = 'EUR', iif(MWStBetrag<=0, '+', '-') +
                   right('00000000000000' +
                   rtrim(cast(abs(MWStBetrag) as varchar(15))),12),null),
                   null) as steuer,                                                     -- Steuer-Betrag
 iif (KopfPos='P', iif(left(WaeCode,3) <> 'EUR', iif(bruttowert>=0, '+', '-') +
                   right('00000000000000' +
                   rtrim(cast(abs(Bruttowert) as varchar(15))),12),null),
                   null) as fwbetrag,                                                     -- Brutto-Betrag
 iif (KopfPos='P', iif(left(WaeCode,3) <> 'EUR', iif(MWStBetrag<=0, '+', '-') +
                   right('00000000000000' +
                   rtrim(cast(abs(MWStBetrag) as varchar(15))),12),null),
                   null) as fwsteuer,                                                     -- Steuer-Betrag
 iif (KopfPos='P', left(MWStSatz_,2) + '.' + right(MWStSatz_,2), null) as prozent,         -- MWStSatz mit Format 20.00
 iif (KopfPos='P', iif(GegenKonto IN ('4097', '4098', '4099', '4101', '4105', '4107', '4115', '4116', '4143', '4150', '4167', '4168', '4169', '4170', '4171', '4331', '4355'), 77, iif(MWStSatz = 0, 7, 1)), null) AS steuercode,
 iif (KopfPos='P',
   iif (Art='R', 'Rechnung ' + rtrim(cast(BelegNr as char(10))),
                 'Gutschrift ' + rtrim(cast(BelegNr as char(10)))), null) as text,             -- Zahlungstext
 iif (KopfPos='P',
    rtrim(iif(Art='R', cast(WnettoTage as char(2)), '0')), null) as zziel,                    -- Zahlungziele siehe Kunde.
 iif (KopfPos='P',
    rtrim(iif(Art='R', cast(wskonto1 as char(2)), '0')), null) as skontopz,                   -- Skonto-Prozente 1
 iif (KopfPos='P',
    rtrim(iif(Art='R', cast(Wskontotage1 as char(2)), '0')), null) as skontotage,             -- Skonto-Betrag 1
 iif (KopfPos='P',
    rtrim(iif(Art='R', cast(Wskonto2 as char(2)), '0')), null) as skontopz2,                  -- Skonto-Prozente 2
 iif (KopfPos='P',
    rtrim(iif(Art='R', cast(Wskontotage2 as char(2)), '0')), null) as skontotage2,            -- Skonto-Betrag 2

 iif (KopfPos='P', 'A' + rtrim(Art), null) as buchsymbol,                                    -- ?
 iif (KopfPos='P', 'A', null) as verbuchkz,                                             -- Buchungs-Kz
 iif (KopfPos='P', 'E', null) as gegenbuchkz,                                           -- Gegenbuchungs.Kz

 iif (KopfPos='P', null, right(rtrim(FirmaSuchcode) + rtrim(Kostenstelle),6)) as kost, -- Kostenstelle
 iif (KopfPos='P', null, Debitor) kotraeger,                                       -- Kostenträger
 iif (KopfPos='P', null, right(ProduktionFiBuNr,2)) as koabteilung,                -- Produktionsstandort
 iif (KopfPos='P', null, right(KdGfFibuNr,2)) as kogeschaeftsbereich,              -- Geschäftsbereich des Kunden
 iif (KopfPos='P', null, iif(detailnetto>=0, '+', '-')+
                   right('00000000000000' +
                   rtrim(cast(abs(Detailnetto) as varchar(15))),12)) as kobetrag,  -- Nettobetrag
 LeistDat_ as leistungsdatum
from #be2
where kopfpos in ('P','S')
order by OrderByAutoInc;