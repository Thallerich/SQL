-- #### Set VsaAnf to status E (only check in, do not create new order) for non-contract articles  ####

UPDATE VsaAnf SET Status = N'E'
FROM VsaAnf, Vsa, Kunden, KdArti, KdBer, Bereich
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Kunden.KdNr IN (2301, 9013, 6071, 7240, 11050, 20000, 24045, 19090)
  AND Vsa.StandKonID = (SELECT StandKon.ID FROM StandKon WHERE StandKon.Bez = N'Produktion GP Enns')
  AND Bereich.Bereich IN (N'SH', N'TW', N'IK')  -- SH = Flachwäsche, TW = Tischwäsche, IK = Inko-Versorgung
  AND KdArti.Vertragsartikel = 0
  AND VsaAnf.Status = N'A'