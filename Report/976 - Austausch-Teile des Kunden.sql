SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa, Teile.Barcode, Status.StatusBez$LAN$ AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Teile.AusdienstDat, CONVERT(char(60), NULL) AS AusdienstGrund, WegGrund.WeggrundBez$LAN$ AS Tauschgrund, Teile.RestwertInfo AS Restwert
FROM Teile, Vsa, Kunden, Artikel, ArtGroe, Status, WegGrund
WHERE Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.Status = Status.Status
  AND Status.Tabelle = 'TEILE'
  AND Teile.WegGrundID = WegGrund.ID
  AND Kunden.ID = $ID$
  AND Teile.Status = 'S'
  AND Teile.AltenheimModus = 0

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa, Teile.Barcode, Status.StatusBez$LAN$ AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Teile.AusdienstDat, Einsatz.EinsatzBez$LAN$ AS AusdienstGrund, WegGrund.WegGrundBez$LAN$ AS Tauschgrund, Teile.AusdRestw AS Restwert
FROM Teile, Vsa, Kunden, Einsatz, Artikel, ArtGroe, Status, WegGrund
WHERE Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.AusdienstGrund = Einsatz.EinsatzGrund
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.Status = Status.Status
  AND Status.Tabelle = 'TEILE'
  AND Teile.WegGrundID = WegGrund.ID
  AND Kunden.ID = $ID$
  AND Teile.Status > 'S'
  AND Teile.AltenheimModus = 0
  AND Teile.AusdienstGrund IN ('A', 'a', 'B', 'b', 'C', 'c')
  AND Teile.AusdienstDat BETWEEN $1$ AND $2$;