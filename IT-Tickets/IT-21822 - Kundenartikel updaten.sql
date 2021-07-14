DECLARE @Changed TABLE (
  KdArtiID int,
  IstBestandAnpassOld bit,
  IstBestandAnpassNew bit,
  WebArtikelOld bit,
  WebArtikelNew bit,
  CheckPackMengeOld bit,
  CheckPackMengeNew bit
);

UPDATE KdArti SET IstBestandAnpass = 1, WebArtikel = 1, CheckPackMenge = 1
OUTPUT inserted.ID, deleted.IstBestandAnpass, inserted.IstBestandAnpass, deleted.WebArtikel, inserted.WebArtikel, deleted.CheckPackMenge, inserted.CheckPackMenge
INTO @Changed
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE Kunden.KdNr = 19080
  AND KdArti.Vertragsartikel = 1;

SELECT Kunden.KdNr, Artikel.ArtikelNr, Artikel.ArtikelBez, Changed.IstBestandAnpassOld AS [IstBestand - Alter Wert], Changed.IstBestandAnpassNew AS [IstBestand - Neuer Wert], Changed.WebArtikelOld AS [WebArtikel - Alter Wert], Changed.WebArtikelNew AS [WebArtikel - Neuer Wert], Changed.CheckPackMengeOld AS [Packmenge - Alter Wert], Changed.CheckPackMengeNew AS [Packmenge - Neuer Wert]
FROM @Changed AS Changed
JOIN KdArti ON Changed.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID;