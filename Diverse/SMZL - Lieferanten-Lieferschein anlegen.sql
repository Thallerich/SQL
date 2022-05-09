drop table #lieflsko_erstellen;
select distinct bko.bestnr, BKo.LiefID, BKo.ID BKoID, BPo.ID BPoID, -1 LiefLsKoID
into #lieflsko_erstellen
from bko, bpo, auftrag, entnko
where bko.intauftragid = auftrag.id
and auftrag.id = entnko.auftragid
and bpo.bkoid = bko.id
and entnko.id = 2922624 
and bpo.id > -1;

insert into LiefLsKo (Status, LiefID, LsNr, Datum, SentToSap)
select distinct 'G', LiefID, 'INTERN_' + rtrim(cast(bestnr as nvarchar(20))), '2022-04-24', 1
from #lieflsko_erstellen
where not exists (select id from lieflsko where lieflsko.lsnr = 'INTERN_' + rtrim(cast(#lieflsko_erstellen.bestnr as nvarchar(20))));

update #lieflsko_erstellen set lieflskoid = lieflsko.id
from Lieflsko
where lieflsko.lsnr = 'INTERN_' + rtrim(cast(#lieflsko_erstellen.bestnr as nvarchar(20)));

insert into lieflspo (LiefLsKoID, BPoID, Menge, Ursprungsmenge, LiefInfo)
select distinct LiefLsKoID, BPoID, 0, 0, 'ABS Dummy'
from #lieflsko_erstellen