SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, LsKo.Datum AS Lieferdatum, LsKo.LsNr, Bereich.BereichBez$LAN$ AS Artikelbereich, ServiceMA.Name AS Kundenservice, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, StatusArtikel.StatusBez$LAN$ AS Artikelstatus, StatusKdArti.StatusBez$LAN$ AS Kundenartikelstatus, LsPo.Menge AS Liefermenge, KdArti.WaschPreis AS Bearbeitungspreis, KdArti.Leasingpreis, KdArti.Periodenpreis, LsPo.EPreis AS [Einzelpreis lt. LS]
FROM LsPo, LsKo, Vsa, Kunden, KdGf, KdArti, Artikel, KdBer, Bereich, Status AS StatusArtikel, Status AS StatusKdArti, Mitarbei AS ServiceMA
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.Status = StatusArtikel.Status
  AND StatusArtikel.Tabelle = N'ARTIKEL'
  AND KdArti.Status = StatusKdArti.Status
  AND StatusKdArti.Tabelle = N'KDARTI'
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND KdBer.ServiceID = ServiceMA.ID
  AND Bereich.ID IN ($3$)
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND KdGf.ID IN ($4$)
  AND KdArti.WaschPreis = 0 
  AND KdArti.LeasingPreis = 0
  AND KdArti.PeriodenPreis = 0
  AND LsPo.Kostenlos = 0
  AND LsPo.Menge > 0
  AND (KdArti.Status = N'I' OR Artikel.Status IN (N'D', N'E', N'I'))
ORDER BY SGF, Kunden.KdNr, Vsa.VsaNr, LsKo.Datum, Artikel.ArtikelNr;