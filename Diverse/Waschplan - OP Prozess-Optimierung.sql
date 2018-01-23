select * 
from kunden 
where id in (
	select kundenid 
	from vsa 
	where id in (
		-- alle VSAs für die eine VSA-Tour existiert, bei der die Tour am Montag oder Dienstag
		-- gefahren wird. Außerdem muss der Bereich der VsaTour dem Bereich "OP" entsprechen
		select distinct vsaid 
		from vsatour 
		where liefvsatourid in (
			select id 
			from vsatour 
			where tourenid in (
				select id 
				from touren 
				where wochentag in ('1', '2') 
				and Touren.Status = 'A'
			)
		)
		and kdberid in (
			select id 
			from kdber 
			where bereichid in (106) 
			and status = 'A'
		)
	)
	and standkonid = 58
	group by 1
)
and firmaid = 2
and status = 'A'
order by 3;

