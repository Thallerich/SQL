SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, JahrLief.Jahr, JahrLief.Lieferwochen
FROM VsaLeas
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN JahrLief ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS' AND JahrLief.Jahr = DATEPART(year, GETDATE()) + 1
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID
JOIN Touren ON VsaTour.TourenID = Touren.ID
WHERE Touren.ExpeditionID IN (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode IN (N'SAWR', N'SA22'))
  AND KdBer.BereichID = (SELECT ID FROM Bereich WHERE Bereich.Bereich = N'HW')
  AND ISNULL(VsaLeas.AusDienst, N'2099/52') > N'2020/52';