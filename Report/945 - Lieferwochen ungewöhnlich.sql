SELECT Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], JahrLief.Lieferwochen, Vsa.ID AS VsaID
FROM JahrLief
JOIN Vsa ON JahrLief.TableID = Vsa.ID AND JahrLief.TableName = N'VSA'
JOIN Kunden oN Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE (JahrLief.Lieferwochen LIKE N'%X@_X@_X@_X@_X%' ESCAPE N'@' OR LEN(JahrLief.Lieferwochen) - LEN(REPLACE(JahrLief.Lieferwochen, N'_', N'')) >= 30) 
  AND Vsa.Status = N'A'
  AND Firma.ID IN ($1$);

SELECT Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.Variante, VsaLeas.Menge, KdArti.LeasingPreis, JahrLief.Lieferwochen, VsaLeas.ID AS VsaLeasID
FROM JahrLief
JOIN VsaLeas ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS'
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE JahrLief.Lieferwochen LIKE N'%X@_X@_X@_X@_X%' ESCAPE N'@'
  AND VsaLeas.Menge <> 0
  AND KdArti.LeasingPreis <> 0
  AND Vsa.Status = N'A'
  AND Firma.ID IN ($1$);