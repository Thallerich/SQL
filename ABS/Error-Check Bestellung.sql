select *
from abslog a
where a.systemuser_id = 261
and a.timestamp >= sysdate-7
and a.message like '%Error%'
order by a.timestamp desc