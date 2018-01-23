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