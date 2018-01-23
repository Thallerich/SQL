UPDATE KdArti 
SET AfaWochen = 10000;

----- Checkliste für Restwertneuberechnung laufen lassen! ----

UPDATE Teile 
SET AusdRestw = RestwertInfo 
WHERE Ausdienst IS NOT NULL 
	AND AusdRestw <> RestwertInfo
	AND KdArtiID = 21964;

UPDATE TeileLag
SET TeileLag.Restwert = Teile.RestwertInfo
FROM TeileLag INNER JOIN Teile ON TeileLag.Barcode = Teile.Barcode
WHERE Teile.Ausdienst IS NOT NULL
  AND Teile.KdArtiID = 21964;

UPDATE RPo
SET RPo.EPreis = Teile.RestwertInfo, RPo.GPreis = Teile.RestwertInfo
FROM RPo 
	INNER JOIN Teile ON TRIM(SUBSTRING(RPo.Memo, POSITION('Barcode' IN RPo.Memo) + 8, 10)) = Teile.Barcode 
	INNER JOIN RKo ON RPo.RKoID = RKo.ID
WHERE RPo.RPoTypeID = 23
	AND RKo.Status = 'A'
	AND RKo.RechNr < 0;