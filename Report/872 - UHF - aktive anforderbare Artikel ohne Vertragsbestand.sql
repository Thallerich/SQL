WITH VsaAnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSAANF'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Name AS Kundenservice, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration], Produktion.SuchCode AS Produktion, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, VsaAnfStatus.StatusBez AS [Status anf. Artikel], VsaAnf.Bestand AS Vertragsbestand, VsaAnf.BestandIst AS [Ist-Bestand]
FROM VsaAnf
JOIN VsaAnfStatus ON VsaAnf.Status = VsaAnfStatus.Status
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN VsaBer ON VsaBer.KdBerID = KdBer.ID AND VsaBer.VsaID = Vsa.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Mitarbei AS Kundenservice ON KdBer.ServiceID = Kundenservice.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
WHERE VsaAnf.Status = N'A'
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND KdGf.KurzBez != N'INT'
  AND ((KdBer.AnfAusEpo > 1 AND VsaBer.AnfAusEpo = -1) OR VsaBer.AnfAusEpo > 1)
  AND (KdBer.IstBestandAnpass = 1 OR KdArti.IstBestandAnpass = 1)
  AND VsaAnf.Bestand = 0
  AND VsaAnf.BestandIst != 0
  AND (
    EXISTS (
      SELECT OPTeile.*
      FROM OPTeile
      WHERE OPTeile.ArtikelID = Artikel.ID
        AND OPTeile.VsaID = Vsa.ID
        AND OPTeile.LastActionsID IN (102, 120, 136)
        AND OPTeile.LastErsatzFuerKdArtiID < 0
        AND (VsaAnf.ArtGroeID = -1 OR (Bereich.VsaAnfGroe = 1 AND OPTeile.ArtGroeID = VsaAnf.ArtGroeID))
    )
    OR EXISTS (
      SELECT OPTeile.*
      FROM OPTeile
      JOIN KdArti ON LastErsatzFuerKdArtiID = KdArti.ID
      WHERE KdArti.ArtikelID = Artikel.ID
        AND OPTeile.VsaID = Vsa.ID
        AND OPTeile.LastActionsID IN (102, 120, 136)
        AND OPTeile.LastErsatzFuerKdArtiID > 0
        AND (VsaAnf.ArtGroeID = -1 OR (Bereich.VsaAnfGroe = 1 AND OPTeile.LastErsatzArtGroeID = VsaAnf.ArtGroeID))
    )
  )
ORDER BY KdNr, VsaNr, ArtikelNr, GroePo.Folge;