-- #### Job xxx ###
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

-- #### Check for non-contract articles with a defined contract amount - these should not exists! ####
/* 
SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Bestand, VsaAnf.BestandIst, VsaAnf.AusstehendeReduz
FROM VsaAnf, Vsa, Kunden, KdArti, Artikel, KdBer, Bereich
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Kunden.KdNr IN (2301, 9013, 6071, 7240, 11050, 20000, 24045, 19090)
  AND Vsa.StandKonID = (SELECT StandKon.ID FROM StandKon WHERE StandKon.Bez = N'Produktion GP Enns')
  AND Bereich.Bereich IN (N'SH', N'TW', N'IK')
  AND KdArti.Vertragsartikel = 0
  AND VsaAnf.Status = N'A'
  AND VsaAnf.Bestand <> 0 
*/

-- #### Job yyy ####
-- #### Correct the replacement articles (by attaching them to their corresponding main article)  ####
-- #### Has to run before checklists so that current stock at customer is corrected by system checklist 174 ####
DECLARE @ErsatzArti TABLE (
  ID int, ArtikelID int, 
  KundenID int, 
  ErsatzFuerKdArtiID int
);

INSERT INTO @ErsatzArti
SELECT KdArti.ID, KdArti.ArtikelID, KdArti.KundenID, KdArti.ErsatzFuerKdArtiID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE Kunden.KdNr IN (2301, 9013, 6071, 7240, 11050, 20000, 24045, 19090)
  AND KdArti.ErsatzFuerKdArtiID > 0;

UPDATE OPTeile SET OPTeile.LastErsatzFuerKdArtiID = x.ErsatzFuerKdArtiID
FROM OPTeile, (
  SELECT OPTeile.ID, ErsatzArti.ErsatzFuerKdArtiID
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN @ErsatzArti AS ErsatzArti ON ErsatzArti.ArtikelID = OPTeile.ArtikelID AND ErsatzArti.KundenID = Kunden.ID
  WHERE OPTeile.Status = N'R'
    AND OPTeile.LastErsatzFuerKdArtiID < 0
    AND Kunden.KdNr IN (2301, 9013, 6071, 7240, 11050, 20000, 24045, 19090)
    AND Vsa.StandKonID = (SELECT StandKon.ID FROM StandKon WHERE StandKon.Bez = N'Produktion GP Enns')
) AS x
WHERE OPTeile.ID = x.ID;