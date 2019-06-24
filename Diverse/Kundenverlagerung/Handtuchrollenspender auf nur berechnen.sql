UPDATE JahrLief SET Lieferwochen = N'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
--SELECT VsaLeas.*, JahrLief.*
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN JahrLief ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS'
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE Artikel.ArtikelNr IN (N'H100', N'H105', N'H105Z', N'H108', N'H108Z', N'H110', N'H100W', N'A7182A')
  AND JahrLief.Jahr >= 2019
  AND JahrLief.Lieferwochen <> N'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
  AND Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'SMW');