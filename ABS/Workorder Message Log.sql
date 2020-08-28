select a.message, a.timestamp
from abslog a
where a.logsource = 'pack_itm' --wo Schnittstelle
and a.timestamp >= sysdate - 1  --Einträge der letzten Woche
ORDER BY a.timestamp DESC;