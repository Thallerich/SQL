DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VariantBez AS Variante, SUM(VsaLeas.Menge) AS Stand
FROM VsaLeas
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN JahrLief ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS' AND JahrLief.Jahr = 2020
WHERE Bereich.Bereich = N'MA'
  AND @Woche BETWEEN VsaLeas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52')
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Vsa.Status = N'A'
  AND SUBSTRING(JahrLief.Lieferwochen, 24, 1) != N'_'
  AND EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    JOIN Standort ON Touren.ExpeditionID = Standort.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND VsaTour.KdBerID = KdBer.ID
      AND Standort.SuchCode = N'GRAZ'
  )
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.Vsanr, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.VariantBez;