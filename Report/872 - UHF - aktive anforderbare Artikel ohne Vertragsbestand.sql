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
LEFT JOIN (
  SELECT VsaAnfSo.VsaAnfID, SUM(VsaAnfSo.AusstehendeReduz) AS OffeneEinmLief
  FROM VsaAnfSo
  WHERE VsaAnfSo.AusstehendeReduz > 0
    AND VsaAnfSo.Art != N'V'
  GROUP BY VsaAnfSo.VsaAnfID
) ReduzEinmalig ON ReduzEinmalig.VsaAnfID = Vsaanf.ID
WHERE VsaAnf.Status = N'A'
  AND UPPER(VsaAnf.Art) = N'M'
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND KdGf.KurzBez != N'INT'
  AND KdBer.ServiceID IN ($1$)
  AND ((KdBer.AnfAusEpo > 1 AND VsaBer.AnfAusEpo = -1) OR VsaBer.AnfAusEpo > 1)
  AND (KdBer.IstBestandAnpass = 1 OR KdArti.IstBestandAnpass = 1)
  AND VsaAnf.Bestand = 0 
  AND VsaAnf.AusstehendeReduz < 1 -- Ticket 60325
  AND ReduzEinmalig.OffeneEinmLief IS NULL -- Ticket 60325
  AND (VsaAnf.BestandIst != 0 OR (VsaAnf.BestandIst - VsaAnf.AusstehendeReduz - ISNULL(ReduzEinmalig.OffeneEinmLief, 0) > 0)) 
  AND Bereich.Bereich != N'LW'
  AND (
    EXISTS (
      SELECT EinzTeil.*
      FROM EinzTeil
      WHERE EinzTeil.ArtikelID = Artikel.ID
        AND EinzTeil.VsaID = Vsa.ID
        AND EinzTeil.LastActionsID IN (102, 120, 136)
        AND EinzTeil.LastErsatzFuerKdArtiID < 0
        AND (VsaAnf.ArtGroeID = -1 OR (Bereich.VsaAnfGroe = 1 AND EinzTeil.ArtGroeID = VsaAnf.ArtGroeID))
    )
    OR EXISTS (
      SELECT EinzTeil.*
      FROM EinzTeil
      JOIN KdArti ON LastErsatzFuerKdArtiID = KdArti.ID
      WHERE KdArti.ArtikelID = Artikel.ID
        AND EinzTeil.VsaID = Vsa.ID
        AND EinzTeil.LastActionsID IN (102, 120, 136)
        AND EinzTeil.LastErsatzFuerKdArtiID > 0
        AND (VsaAnf.ArtGroeID = -1 OR (Bereich.VsaAnfGroe = 1 AND EinzTeil.LastErsatzArtGroeID = VsaAnf.ArtGroeID))
    )
  )
ORDER BY KdNr, VsaNr, ArtikelNr, GroePo.Folge;