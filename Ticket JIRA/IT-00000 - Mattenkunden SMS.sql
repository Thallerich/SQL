DECLARE @WocheAktuell nchar(7) = (
  SELECT Week.Woche
  FROM Week
  WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat
);

SELECT Standort.SuchCode AS Hauptstandort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.VariantBez AS Variante
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE @WocheAktuell BETWEEN VsaLeas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52')
  AND Bereich.Bereich = N'MA'
  AND Standort.SuchCode = N'SMS'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Vsa.Status = N'A'
ORDER BY Hauptstandort, KdNr, VsaNr, ArtikelNr;