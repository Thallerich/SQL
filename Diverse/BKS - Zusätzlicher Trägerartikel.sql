DECLARE @ArtiIDAlt integer;
DECLARE @ArtiIDNeu integer;
DECLARE @KundenID integer;

SET @ArtiIDAlt = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'3084043303');
SET @ArtiIDNeu = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'3084043305');
SET @KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.Kdnr = 31066);

INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, MengeKredit)
SELECT Vsa.ID AS VsaID, Traeger.ID AS TraegerID, 
  (SELECT Groesse.ID FROM ArtGroe AS Groesse WHERE Groesse.ArtikelID = @ArtiIDNeu AND Groesse.Groesse = ArtGroe.Groesse) AS ArtGroeID,
  (SELECT KdArti.ID FROM KdArti WHERE KdArti.KundenID = @KundenID AND KdArti.ArtikelID = @ArtiIDNeu) AS KdArtiID,
  TraeArti.MengeKredit
FROM TraeArti, Traeger, Vsa, KdArti, ArtGroe
WHERE TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND KdArti.ArtikelID = @ArtiIDAlt
  AND Vsa.KundenID = @KundenID
  AND Vsa.RentomatID > 0
  AND Traeger.Status = 'A'
  AND Traeger.RentoArtID = 2
  AND NOT EXISTS (
    SELECT TraeArti.*
    FROM TraeArti, KdArti
    WHERE TraeArti.KdArtiID = KdArti.ID
      AND TraeArti.TraegerID = Traeger.ID
      AND KdArti.ArtikelID = @ArtiIDNeu
  );