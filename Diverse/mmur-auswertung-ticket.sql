SELECT KdNr, CONVERT(DateTime, SQL_DATE), sum(Eingang) as "Summe Eingang", sum(Ausgang) as "Summe Ausgang",
       sum(Nachwaesche) as "Teile Nachwäsche", sum(Reparatur) as "Teile Reparatur",
       sum(Rueckgabe) as "Teile Rückgabe", sum(Aufbuegeln) as "Teile Aufbuegeln"
FROM (SELECT KdNr, Barcode, DateTime, ZielNrID, ZielNr.Bez as Ziel, Menge,
       IIF(Menge=1,1,0) as Eingang,
       IIF(Menge=-1,1,0) as Ausgang,
       IIF(ZielNr.Bez LIKE 'Enns1: Aufbügeln%',1,0) as Aufbuegeln,
       IIF(ZielNr.Bez LIKE 'Enns1: Reparatur%',1,0) as Reparatur,
       IIF(ZielNr.Bez LIKE 'Enns1: Lager Rückgabe',1,0) as Rueckgabe,
	   IIF(ZielNr.Bez LIKE '%Nachwäsche%',1,0) as Nachwaesche
      FROM Teile, KdArti, Kunden, Scans, ZielNr
      WHERE KdArtiID=KdArti.ID and KundenID=Kunden.ID and /*Kunden.ID=$ID$ and*/
       TeileID=Teile.ID and /*convert(DateTime, sql_date)=$1$ and*/
       ZielNrID=ZielNr.ID ) a
GROUP BY 1,2