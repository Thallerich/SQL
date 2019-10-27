UPDATE JahrLief SET Lieferwochen = N'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
--SELECT VsaLeas.*, JahrLief.*
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN JahrLief ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS'
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE Artikel.ArtikelNr IN (N'H100', N'H105', N'H105Z', N'H108', N'H108Z', N'H110', N'H100W', N'A7182A', N'H096', N'H097', N'H098', N'H099', N'H099W', N'H105W', N'H108W', N'H110W', N'H115W', N'096W', N'H097W', N'H098W')
  AND JahrLief.Jahr >= 2019
  AND JahrLief.Lieferwochen <> N'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
  AND Kunden.StandortID IN (SELECT ID FROM Standort WHERE Suchcode IN (N'SMS', N'MATT'));