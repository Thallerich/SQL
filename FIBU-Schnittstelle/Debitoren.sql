SELECT Debitor, Name1, Name2, Strasse, Land.IsoCode3, Plz, Ort, SkontoTage, Skonto, SkontoTage2, Skonto2, NettoTage, UStIdNr
FROM #DebitorExport DE
LEFT OUTER JOIN Land ON DE.Land = Land.IsoCode
WHERE (LEN(Debitor) = 7 AND LEFT(Debitor, 2) IN ('23', '24', '25', '27'))
  OR (LEN(Debitor) = 9 AND LEFT(Debitor, 2) IN ('27', '28'))
  OR (LEN(Debitor) = 6 AND LEFT(Debitor, 2) IN ('28'));