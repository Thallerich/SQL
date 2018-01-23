SELECT DISTINCT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, KundenStatus.StatusBez$LAN$ AS [Status Kunde], Vsa.VsaNr, Vsa.SuchCode AS Stichwort, Vsa.Bez AS Vsa, VsaStatus.StatusBez$LAN$ AS [Status VSA], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtikelStatus.StatusBez$LAN$ AS [Status Artikel], VsaAnfStatus.StatusBez$LAN$ AS [Status anforderbarer Artikel]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Status AS VsaAnfStatus ON VsaAnf.Status = VsaAnfStatus.Status AND VsaAnfStatus.Tabelle = N'VSAANF'
JOIN Status AS VsaStatus ON Vsa.Status = VsaStatus.Status AND VsaStatus.Tabelle = N'VSA'
JOIN Status AS KundenStatus ON Kunden.Status = KundenStatus.Status AND KundenStatus.Tabelle = N'KUNDEN'
JOIN Status AS ArtikelStatus ON Artikel.Status = ArtikelStatus.Status AND ArtikelStatus.Tabelle = N'ARTIKEL'
WHERE Artikel.ArtGruID = 70  -- Artikelgruppe Instrumente