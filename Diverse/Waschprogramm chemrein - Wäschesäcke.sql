SELECT *
FROM Artikel
WHERE WaschPrgID=4

SELECT *
FROM KdArti
WHERE WaschPrgID=4

SELECT Kunden.KdNr, TRIM(ISNULL(Kunden.Name1,''))+' '+TRIM(ISNULL(Kunden.Name2,''))+' '+TRIM(ISNULL(Kunden.Name3,'')) Kunde
FROM Teile, Vsa, Kunden
WHERE WaschPrgID=4
 AND Teile.VsaID = Vsa.ID
 AND Vsa.KundenID = Kunden.ID
GROUP BY 1,2

SELECT *
FROM WaschCh
WHERE WaschPrgID=4


--------------------------------------------------------------------------------------------------------------------------------


SELECT Traeger.ID, Traeger.Traeger, Traeger.Hinweise FROM Traeger WHERE Hinweise LIKE ('%rot% WS%')
