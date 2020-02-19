DECLARE @ArtiIDAlt integer;
DECLARE @ArtiIDNeu integer;
DECLARE @KundenID integer;

SET @ArtiIDAlt = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'203630010144');
SET @ArtiIDNeu = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'202504000026');
SET @KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.Kdnr = 11804);

-- (VsaID, TraegerID, ArtGroeID, KdArtiID)
SELECT Vsa.ID AS VsaID, Traeger.ID AS TraegerID, 
  (SELECT Groesse.ID FROM ArtGroe AS Groesse WHERE Groesse.ArtikelID = @ArtiIDNeu AND Groesse.Groesse = ArtGroe.Groesse) AS ArtGroeID,
  (SELECT KdArti.ID FROM KdArti WHERE KdArti.KundenID = @KundenID AND KdArti.ArtikelID = @ArtiIDNeu) AS KdArtiID
FROM TraeArti, Traeger, Vsa, KdArti, ArtGroe
WHERE TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND KdArti.ArtikelID = @ArtiIDAlt
  AND Vsa.KundenID = @KundenID
  AND Vsa.RentomatID > 0
  AND Traeger.Status = 'A'
  AND NOT EXISTS (
    SELECT TraeArti.*
    FROM TraeArti, KdArti
    WHERE TraeArti.KdArtiID = KdArti.ID
      AND TraeArti.TraegerID = Traeger.ID
      AND KdArti.ArtikelID = @ArtiIDNeu
  );