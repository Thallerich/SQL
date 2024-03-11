DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @SoFaArtikelID int = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'PSANEUTEIL' AND Artikel.ArtiTypeID = 6);

INSERT INTO KdArPsa (KdArtiID, SoFaArtikelID, Frequenz, StartWaeschen, StopWaeschen, AnlageUserID_, UserID_)
SELECT KdArti.ID AS KdArtiID, @SoFaArtikelID, PsaVorgabe.Frequenz, PsaVorgabe.StartWaeschen, PsaVorgabe.StopWaeschen, @UserID, @UserID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN _IT80750 ON Kunden.KdNr = _IT80750.KdNr AND Artikel.ArtikelNr = _IT80750.ArtikelNr AND KdArti.Variante = _IT80750.Variante
CROSS JOIN (SELECT ArtiSoFa.* FROM ArtiSoFa WHERE ArtiSofa.ArtikelID = @SoFaArtikelID) AS PsaVorgabe
WHERE NOT EXISTS (
  SELECT KdArPsa.*
  FROM KdArPsa
  WHERE KdArPsa.KdArtiID = KdArti.ID
    AND KdArPsa.SoFaArtikelID = @SoFaArtikelID
);

GO

DROP TABLE _IT80750;
GO