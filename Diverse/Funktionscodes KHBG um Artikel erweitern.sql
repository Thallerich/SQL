DECLARE @ArtiAlt char(12);
DECLARE @ArtiNeu char(12);

SET @ArtiAlt = '203035400001';
SET @ArtiNeu = '202505069505';

INSERT INTO KdAusArt
SELECT GetNextID('KDAUSART') AS ID, x.KdAusstaID, (
  SELECT KdArti.ID 
  FROM KdArti, Artikel
  WHERE KdArti.ArtikelID = Artikel.ID 
    AND KdArti.KundenID = x.KundenID
    AND Artikel.ArtikelNr = @ArtiNeu
    AND KdArti.Variante = '-'
) AS KdArtiID, (
  SELECT MAX(KdAusArt.Pos) + 10 
  FROM KdAusArt 
  WHERE KdAusArt.KdAusstaID = x.KdausstaID
) AS Pos, x.Menge, GETDATE() AS Anlage_, GETDATE() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
FROM (
  SELECT DISTINCT KdAusArt.KdAusstaID, Kunden.ID AS KundenID, KdAusArt.Menge
  FROM KdAussta, KdAusArt, Kunden, Holding, KdArti, Artikel
  WHERE KdAussta.RentomatCode = 1
    AND KdAussta.ID = KdAusArt.KdAusstaID
    AND KdAussta.KundenID = Kunden.ID
    AND Kunden.HoldingID = Holding.ID
    AND Holding.Holding = 'KHBG'
    AND KdAusArt.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.ArtikelNr = @ArtiAlt
    AND KdAussta.ID NOT IN (
      SELECT z.KdAusstaID
      FROM KdAusArt z, KdArti, Artikel
      WHERE z.KdArtiID = KdArti.ID
        AND KdArti.ArtikelID = Artikel.ID
        AND Artikel.ArtikelNr = @ArtiNeu
    )
) AS x;