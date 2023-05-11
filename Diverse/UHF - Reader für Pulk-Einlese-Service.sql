SELECT ZielNr.ZielNrBez, ZielNr.Funktion, CAST(ArbPSetT.Wert AS nchar(15)) AS IP
FROM ArbPSetT
JOIN ZielNr ON ArbPSetT.ZielNrID = ZielNr.ID
WHERE ArbPSetT.ZielNrID > 0
  AND ArbPSetT.Bereich = N'UHFReader'
  AND ArbPSetT.Schluessel = N'IP'
  AND ZielNr.Funktion = N'E';