/*
drop table _KdArtiFuerRechPo;
drop table _RechPoNachtrag;
drop table _NeuRechKo;
drop table _NeuRechPo;
*/

DECLARE @datefrom date, @dateto date, @rechdat date = N'2023-10-31';
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DROP TABLE IF EXISTS #Customer;

CREATE TABLE #Customer (
  KundenID int PRIMARY KEY CLUSTERED,
  KdNr int NOT NULL,
  Prozentsatz numeric(18, 4),
  RechMemotext nvarchar(107)
);

/* 
SET @datefrom = CAST(N'2023-07-01' AS date);
SET @dateto = CAST(N'2023-09-30' AS date);

INSERT INTO #Customer (KundenID, KdNr, Prozentsatz, RechMemotext)
SELECT DISTINCT Kunden.ID, Kunden.KdNr, PePo.PeProzent, N'Rechnung aufgrund der nachträglichen Preiserhöhung vom ' + FORMAT(PeKo.WirksamDatum, N'dd.MM.yyyy', N'de-AT') + N' rückwirkend zum ' + FORMAT(@datefrom, N'dd.MM.yyyy', N'de-AT') + N' zur Rechnung ' AS RechMemotext
FROM PePo
JOIN PeKo ON PePo.PeKoID = PeKo.ID
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE (PeKo.Bez IN (N'PE JULI V MED SEPTEMBER AUVA', N'PE JULI V MED SEPTEMBER', N'DIAK PL 10,5', N'SALK 10,5%') OR (PeKo.Bez = N'PE Nachträge DIVERS' AND KdGf.KurzBez = N'MED'))
  AND Kunden.AdrArtID = 1
  AND PePo.PeProzent != 0
  AND PePo.[Status] = N'A';
 */

SET @datefrom = CAST(N'2023-07-01' AS date);
SET @dateto = CAST(N'2023-10-31' AS date);

INSERT INTO #Customer (KundenID, KdNr, Prozentsatz, RechMemotext)
SELECT DISTINCT Kunden.ID, Kunden.KdNr, PePo.PeProzent, N'Rechnung aufgrund der nachträglichen Preiserhöhung vom ' + FORMAT(PeKo.WirksamDatum, N'dd.MM.yyyy', N'de-AT') + N' rückwirkend zum ' + FORMAT(@datefrom, N'dd.MM.yyyy', N'de-AT') + N' zur Rechnung ' AS RechMemotext
FROM PePo
JOIN PeKo ON PePo.PeKoID = PeKo.ID
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE PeKo.Bez = N'CARITAS 8,9%'
  AND Kunden.AdrArtID = 1
  AND PePo.PeProzent != 0
  AND PePo.[Status] = N'A';



-- Ermittlung der PE-Daten
/*
select distinct KdArti.ID KdArtIID, KdArti.ArtikelID, KdArti.KundenID, KdArti.KdBerID, PePo.PeProzent, 
PrArchiv.WaschPreis, PrArchiv.LeasPreis, PrArchiv.VkPreis, PrArchiv.Sonderpreis
into _KdArtiFuerRechPo
from PrArchiv, KdArti, PeKo, PePo, Vertrag
where PrArchiv.PeKoID = PeKo.ID
and PeKo.Bez = 'GRAZ PE JUL 2020'
and PePo.PeKoID = PeKo.ID
and PePo.VertragID = Vertrag.ID
and Vertrag.KundenID = KdArti.KundenID
and PrArchiv.KdArtiID = KdArti.ID;
*/
select distinct KdArti.ID KdArtIID, KdArti.ArtikelID, KdArti.KundenID, KdArti.KdBerID, #Customer.Prozentsatz PeProzent
--, PrArchiv.WaschPreis, PrArchiv.LeasPreis, PrArchiv.VkPreis, PrArchiv.Sonderpreis
into _KdArtiFuerRechPo
from KdArti
join #Customer ON KdArti.KundenID = #Customer.KundenID;
-- select * from #KdArtiFuerRechPo where kdartiid = 34925819

-- Ermittlung der Rechnungspositionen
select RechKo.RechNr, RechKo.RechDat, RechPo.Menge, RechPo.EPreis, RechPo.GPreis, RechPo.KdArtiID, k.PeProzent, 
RechPo.Rabatt RabattAlt, RechPo.RabattProz,
--k.WaschPreis, k.LeasPreis, k.VkPreis, k.Sonderpreis
Round(RechPo.EPreis*((100+k.PeProzent)/100),3) EPreisNeu,
(Round(RechPo.EPreis*((100+k.PeProzent)/100),3) - RechPo.EPreis) AbrechnungEPreis,
Round((Round(RechPo.EPreis*((100+k.PeProzent)/100),3) - RechPo.EPreis) * RechPo.Menge,2) AbrechnungGPreisOhneRabatt,
Round(Round((Round(RechPo.EPreis*((100+k.PeProzent)/100),3) - RechPo.EPreis) * RechPo.Menge,2)*(RabattProz/100),2) RabattNeu,
Round((Round(RechPo.EPreis*((100+k.PeProzent)/100),3) - RechPo.EPreis) * RechPo.Menge,2) -
Round(Round((Round(RechPo.EPreis*((100+k.PeProzent)/100),3) - RechPo.EPreis) * RechPo.Menge,2)*(RabattProz/100),2) AbrechnungGPreis,
RechKo.ID AltRechKoID, RechPo.ID AltRechPoID, -1 NeuRechKoID, -1 NeuRechPoID
into _RechPoNachtrag
from RechKo, RechPo, _KdArtiFuerRechPo k, Kunden
where RechPo.RechKoID = RechKo.ID
and k.KdArtiID = RechPo.KdArtiID
and RechKo.KundenID = Kunden.ID
--and Kunden.KdNr = 272087
and RechKo.RechDat between @datefrom AND @dateto
and RechKo.Art = 'R'
order by RechKo.RechDat, RechKo.RechNr;
-- select distinct rechnr from _RechPoNachtrag

-- Erstellung der neuen Rechnung Start
select *, -1 NeuRechKoID
into _NeuRechKo
from RechKo
where ID in (select AltRechKoID from _RechPoNachtrag);

update _NeuRechKo set NeuRechKoID = NEXT VALUE FOR NextID_RechKo;

update _RechPoNachtrag set NeuRechKoID = _NeuRechKo.NeuRechKoID
from _NeuRechKo
where _NeuRechKo.ID = _RechPoNachtrag.AltRechKoID;

-- zu diesem Zeitpunkt ist _NeuRechKo.RechNr noch die alte Rechnung auf deren Basis die neue Rechnung erstellt wird
update _NeuRechKo set Memo = #Customer.RechMemotext + rtrim(cast(_NeuRechKo.RechNr as char))
from #Customer
WHERE _NeuRechKo.KundenID = #Customer.KundenID;
-- select * from _NeuRechKo;

update _NeuRechKo set ID = NeuRechKoID;
alter table _NeuRechKo drop column NeuRechKoID;
-- Erstellung der neuen Rechnung Ende
-- drop table _NeuRechPo

-- Erstellung der neuen Rechnungpositionen Start
select *, -1 NeuRechPoID
into _NeuRechPo
from RechPo
where ID in (select AltRechPoID from _RechPoNachtrag);

update _NeuRechPo set NeuRechPoID = NEXT VALUE FOR NextID_RechPo;

update _RechPoNachtrag set NeuRechPoID = _NeuRechPo.NeuRechPoID
from _NeuRechPo
where _NeuRechPo.ID = _RechPoNachtrag.AltRechPoID;

update _NeuRechPo set ID = NeuRechPoID;
alter table _NeuRechPo drop column NeuRechPoID;

update _NeuRechPo set RechKoID = _RechPoNachtrag.NeuRechKoID
from _RechPoNachtrag
where _RechPoNachtrag.NeuRechPoID = _NeuRechPo.ID;
-- Erstellung der neuen Rechnungpositionen Ende

-- select * from _RechPoNachtrag
-- select * from #NeuRechKo
-- select * from #NeuRechPo

-- Anpassung der Rechnung 
update _NeuRechKo set RechNr = -ID-2, RechDat = @rechdat, Status = 'A', Nettowert = 0, NettowertVertWae = 0, MwStBetrag = 0, Bruttowert = 0, BruttoWertRund = 0, DruckDatum = null, MailDatum = null, FaelligDat = null, FibuExpID = -1, AnlGesendet = 0, FreigabeMitarID = -1, FreigabeZeit = null, DruckZeitpunkt = null, Arbeitswert = 0, AnlGesendetDatum = null, DruckMitarbeiID = -1, SteuerDat = null, MwStDat = null, RKoTypeID = 93, Anlage_ = GetDate(), Update_ = GetDate(), AnlageUserID_ = @UserID, UserID_ = @UserID;
-- select * from RkoType where ID = 93

-- Anpassung der Rechnungspositionen Start
update _NeuRechPo set EPreis = AbrechnungEPreis, EPreisVertWae = AbrechnungEPreis, Rabatt =RabattNeu, GPreis = AbrechnungGPreis, GPreisVertWae = AbrechnungGPreis
from _RechPoNachtrag
where _RechPoNachtrag.NeuRechPoID = _NeuRechPo.ID;

insert into RechKo
select * from _NeuRechKo;

insert into RechPo
select * from _NeuRechPo;

/*
select distinct RechKo.*
from Rechko, #RechPoNachtrag
where #RechPoNachtrag.NeuRechKoID = RechKo.ID;

select *
from RechKo 
where Anlage_ > '2021-11-05 08:00:00'
and anlageuserid_ = 9420;

update rechko set NettoWert = GPreisSum, NettoWertVertWae =  GPreisVertWaeSum
from (
select RechKoID, sum(RechPo.GPreis) GPreisSum, sum(RechPo.GPreisVertWae) GPreisVertWaeSum
from RechKo, RechPo
where RechKo.Anlage_ between  '2021-11-05 08:00:00' and '2021-11-05 10:00:00'
and RechKo.AnlageUserID_ = 9420
and RechKo.RKoTypeID = 93
and RechPo.RechKoID = RechKo.ID
group by RechKoID) daten
where rechko.id = daten.rechkoid
and rechko.Status = 'A';

update rechko set MwStBetrag = (rechko.nettowert*rechko.Mwstsatz/100)
where RechKo.Anlage_ between  '2021-11-05 08:00:00' and '2021-11-05 10:00:00'
and RechKo.AnlageUserID_ = 9420
and RechKo.RKoTypeID = 93
and RechKo.Status = 'A';
update rechko set BruttoWert = MwStBetrag + NettoWert
where RechKo.Anlage_ between  '2021-11-05 08:00:00' and '2021-11-05 10:00:00'
and RechKo.AnlageUserID_ = 9420
and RechKo.RKoTypeID = 93
and RechKo.Status = 'A';
*/
