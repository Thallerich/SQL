SELECT TraegerEx AS MaNr, Nachname AS [Name], Vorname, KarteEx AS Kartennummer, FunktionsCodeEx AS Kleiderprofil, Seks = 
  CASE GeschlechtEx
    WHEN N'M' THEN N'M'
    WHEN N'W' THEN N'F'
    ELSE N'F'
  END
FROM RentexTr
WHERE RentomatID = 54;