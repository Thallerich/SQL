select * 
into #tmpscan 
from scans 
where teileid in (
	select id 
	from teile 
	where ARTIKELid in (
		select ID 
		from artikel 
		where bereichid=108
	)
	and vsaid in (
		select id 
		from vsa 
		where kundenid in (
			select ID 
			from kunden 
			where suchcode like '%SANDOZ%' OR kdNr=5011
		)
	)
)
AND zielnrID=1;

select a.ArtikelNr, a.ArtikelBez, WEEK(ts.DateTime)+"/"+YEAR(ts.DateTime) AS Woche, count(t.ID)
from viewartikel a
JOIN teile t ON (t.artikelID=a.ID)
JOIN #tmpscan ts ON (t.ID=ts.teileID)
group by ArtikelNr,ArtikelBez,Woche;

drop table #tmpscan;