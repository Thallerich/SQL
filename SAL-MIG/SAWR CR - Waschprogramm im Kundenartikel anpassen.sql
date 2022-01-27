DECLARE @WaschPrgPES int = (SELECT ID FROM WaschPrg WHERE WaschPrg = N'PES');
DECLARE @WaschPrgNone int = 907;

UPDATE KdArti SET WaschPrgID = @WaschPrgPES
WHERE ID IN (
  SELECT KdArti.ID AS KdArtiID
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN WaschPrg ON KdArti.WaschPrgID = WaschPrg.ID
  WHERE Bereich.Bereich = N'CR'
    AND WaschPrg.WaschPrg != N'PES'
    AND Artikel.ArtikelNr NOT IN (N'RBRILL', N'RBRIL1')
    AND EXISTS (
      SELECT Teile.*
      FROM Teile
      WHERE Teile.KdArtiID = KdArti.ID
    )
    AND EXISTS (
      SELECT Vsa.*
      FROM Vsa
      JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
      WHERE StandBer.BereichID = Bereich.ID
        AND Vsa.KundenID = KdArti.KundenID
        AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
    )
);

UPDATE KdArti SET WaschPrgID = @WaschPrgNone
WHERE ID IN (
  SELECT KdArti.ID AS KdArtiID
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN WaschPrg ON KdArti.WaschPrgID = WaschPrg.ID
  WHERE Bereich.Bereich = N'CR'
    AND WaschPrg.WaschPrg != N'-'
    AND Artikel.ArtikelNr IN (N'RBRILL', N'RBRIL1')
    AND EXISTS (
      SELECT Teile.*
      FROM Teile
      WHERE Teile.KdArtiID = KdArti.ID
    )
    AND EXISTS (
      SELECT Vsa.*
      FROM Vsa
      JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
      WHERE StandBer.BereichID = Bereich.ID
        AND Vsa.KundenID = KdArti.KundenID
        AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
    )
);