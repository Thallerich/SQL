DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Hauptstandort, KdGf.KurzBez AS Geschäftsbereich, Vsa.VsaNr AS VSANr, Vsa.Bez AS VSA, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, Mengenleasing.Lieferwochen AS [Lieferwochen Mengenleasing], VsaLief.Lieferwochen AS [Lieferwochen VSA]
FROM VsaLeas
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN JahrLief AS Mengenleasing ON Mengenleasing.TableID = VsaLeas.ID AND Mengenleasing.TableName = N'VSALEAS' AND Mengenleasing.Jahr = 2021
JOIN Jahrlief AS VsaLief ON VsaLief.TableID = Vsa.ID AND VsaLief.TableName = N'VSA' AND VsaLief.Jahr = 2021
WHERE @CurrentWeek BETWEEN VsaLeas.InDienst AND VsaLeas.AusDienst
  --AND LEFT(Mengenleasing.Lieferwochen, 6) IN (N'XB', N'BX')
  AND LEFT(VsaLief.Lieferwochen, 6) != LEFT(Mengenleasing.Lieferwochen, 6)
  AND VsaLief.Lieferwochen != N'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

GO