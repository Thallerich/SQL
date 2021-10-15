USE Salesianer;
GO

-- diese Fälle können raus, da es den gleichen Preis bereits mit LiefPackmenge 1 gibt
delete from ArtiLief where LiefPackMenge = 0 and ArtGroeID > -1
and exists (select * from Artilief a2 where a2.liefid = artilief.liefid and a2.artgroeid = artilief.artgroeid and a2.id <> artilief.id and a2.Ekpreis = artilief.ekpreis and a2.liefpackmenge = 1);

GO
-- diese Fälle ergeben keinen Sinn
delete from ArtiLief where ArtikelID = -1 and ID > -1;

GO
-- diese Fälle sind überflüssig, da immer ein Datensatz mit LiefPackMenge 1 über die Systemchecklisten angelegt wird
delete from ArtiLief where LiefPackMenge = 0 and EkPreis = 0 and ID > -1;

GO
-- wenn es keinen mit LiefPackMenge 1 gibt, dann die mit LiefPackmenge 0 umstellen
update ArtiLief set LiefPackMenge = 1
where LiefPackMenge = 0 and ArtGroeID > -1
and not exists (select * from Artilief a2 where a2.liefid = artilief.liefid and a2.artgroeid = artilief.artgroeid and a2.id <> artilief.id and a2.liefpackmenge = 1);

GO
-- alle ArtiLief wo es keinen anderen gibt, das VonDatum auf null setzen, da sonst unterschiedliche ArtiLief-Datensätze in der 9.30 entstehen (pro VonDatum)
DROP TABLE IF EXISTS _delete_ArtiLief_VonDatum;
GO

select artilief.*
into _delete_ArtiLief_VonDatum
from ArtiLief
where ArtiLief.ArtGroeID > -1
and ArtiLief.VonDatum is not null
and not exists (select * from Artilief a2 where a2.liefid = artilief.liefid and a2.artgroeid = artilief.artgroeid and a2.id <> artilief.id);

update ArtiLief set VonDatum = null where ID in (select ID from _delete_ArtiLief_VonDatum);

GO
-- doppelte aktive Preise pro Größe ermitteln, ggf. zur Prüfung
select Lief.LiefNr, Lief.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, ArtiLief.EkPreis, ArtiLief.ID ArtiLiefID, ArtiLief.VonDatum, ArtiLief.BisDatum
from ArtiLief, (
select ArtiLief.LiefID, ArtiLief.ArtGroeID, count(ArtiLief.ID) Anz
from ArtiLief
where GetDate() between VonDatum and BisDatum
and ArtiLief.ArtGroeID > -1
group by ArtiLief.LiefID, ArtiLief.ArtGroeID
having count(ArtiLief.ID) > 1) Daten, Artikel, ArtGroe, Lief
where ArtiLief.LiefID = Daten.LiefID
and ArtiLief.ArtGroeID = Daten.ArtGroeID
and ArtiLief.ArtikelID = Artikel.ID
and ArtiLief.LiefID = Lief.ID
and ArtGroe.ID = ArtiLief.ArtGroeID
order by LiefNr, ArtikelNr, Groesse, EkPreis;

GO