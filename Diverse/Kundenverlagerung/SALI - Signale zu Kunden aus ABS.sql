SELECT BC, Signalcode, Signalbez, ISNULL(Signaltext, N'') AS Signaltext, Signalstartdatum
FROM OPENQUERY(ABS1, N'
select ui.primaryid     BC,
       f.code           SIGNALCODE,
       fd.description   SIGNALBEZ,
       uif.freetextitem SIGNALTEXT,
       uif.startdate    SIGNALSTARTDATUM
  from uniqueitem ui
  join uniqueitemflag uif
    on ui.uniqueitem_id = uif.uniqueitem_id
  join flag f
    on f.flag_id = uif.flag_id
  join flag_desc fd
    on (f.flag_id = fd.flag_id and fd.language_id = 1)
  join uniqueitemnonpool uinp
    on ui.uniqueitem_id = uinp.uniqueitem_id
  join weareremployment we
    on we.weareremployment_id = uinp.weareremployment_id
  join wearer w
    on w.wearer_id = we.wearer_id
  join customer c
    on c.customer_id = w.customer_id
 where c.customernumber = 10002292
');