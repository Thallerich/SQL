DECLARE @TraeArtiUpdate TABLE (
  TraeArtiID int,
  ArtGroeID int,
  KdArtiID int
);

WITH ArtikelNeu AS (
  SELECT Artikel.ID AS ArtikelID, KdArti.ID AS KdArtiID, ArtGroe.ID AS ArtGroeID, ArtGroe.Groesse, Artikel.ArtikelNr
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Kunden.KdNr = 23044
    AND Artikel.ArtikelNr = N'203084043305'
)
INSERT INTO @TraeArtiUpdate
SELECT TraeArti.ID AS TraeArtiID, ArtikelNeu.ArtGroeID, ArtikelNeu.KdArtiID
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN KdArti AS KdArtiAlt ON TraeArti.KdArtiID = KdArtiAlt.ID
JOIN Artikel AS ArtikelAlt ON KdArtiAlt.ArtikelID = ArtikelAlt.ID
JOIN ArtGroe AS ArtGroeAlt ON TraeArti.ArtGroeID = ArtGroeAlt.ID
JOIN ArtikelNeu ON IIF(ArtGroeAlt.Groesse = N'XXS', N'XS', ArtGroeAlt.Groesse) = ArtikelNeu.Groesse
WHERE Vsa.RentomatID = 39
  AND ArtikelAlt.ArtikelNr = N'203084043303'
  AND Traeger.RentoArtID = 2
  AND NOT EXISTS (
    SELECT Teile.*
    FROM Teile
    WHERE Teile.TraeArtiID = TraeArti.ID
  );

UPDATE TraeArti SET ArtGroeID = TraeArtiUpdate.ArtGroeID, KdArtiID = TraeArtiUpdate.KdArtiID
FROM TraeArti
JOIN @TraeArtiUpdate AS TraeArtiUpdate ON TraeArtiUpdate.TraeArtiID = TraeArti.ID;