SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa, EinzHist.Barcode, Status.StatusBez$LAN$ AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, EinzHist.AusdienstDat, Einsatz.EinsatzBez$LAN$ AS AusdienstGrund, WegGrund.WegGrundBez$LAN$ AS Tauschgrund, EinzHist.AusdRestw AS Restwert
FROM EinzHist, EinzTeil, Vsa, Kunden, Einsatz, Artikel, ArtGroe, Status, WegGrund
WHERE EinzHist.EinzTeilID = EinzTeil.ID
  AND EinzHist.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
  AND EinzHist.ArtikelID = Artikel.ID
  AND EinzHist.ArtGroeID = ArtGroe.ID
  AND EinzHist.Status = Status.Status
  AND Status.Tabelle = 'EINZHIST'
  AND EinzHist.WegGrundID = WegGrund.ID
  AND Kunden.ID = $ID$
  AND EinzHist.AusdienstGrund IN ('d', 'D')
  AND EinzTeil.AltenheimModus = 0
  AND EinzHist.AusdienstDat BETWEEN $1$ AND $2$
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1;