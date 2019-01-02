DECLARE @Update TABLE (
  TraeArtiID int,
  ArtikelID int,
  Groesse nchar(8) COLLATE Latin1_General_CS_AS,
  Laenge nchar(5) COLLATE Latin1_General_CS_AS,
  GrLan nchar(13) COLLATE Latin1_General_CS_AS,
  ArtGroeID int DEFAULT -1
);

INSERT INTO @Update (TraeArtiID, ArtikelID, Groesse, Laenge, GrLan)
SELECT TraeArti.ID AS TraeArtiID, Artikel.ID AS ArtikelID, ArtGroe.Groesse, SZL.Länge AS Laenge, RTRIM(ArtGroe.Groesse) + N'/' + RTRIM(SZL.Länge) AS GrLan
FROM Wozabal.dbo.__SZLLaengenimport AS SZL
JOIN Kunden ON SZL.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID AND SZL.VsaBez = Vsa.Bez
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND SZL.TraegerNr = Traeger.Traeger
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID AND SZL.Traegerartikel = Artikel.ArtikelBez
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID;

INSERT INTO ArtGroe (ArtikelID, Groesse)
SELECT DISTINCT Artikel.ID AS ArtikelID, u.GrLan AS Groesse
FROM @Update AS u
JOIN Artikel ON u.ArtikelID = Artikel.ID
LEFT OUTER JOIN ArtGroe ON u.ArtikelID = ArtGroe.ArtikelID AND u.GrLan = ArtGroe.Groesse
WHERE ArtGroe.ID IS NULL;

UPDATE u SET ArtGroeID = ArtGroe.ID
FROM @Update AS u
JOIN ArtGroe ON u.ArtikelID = ArtGroe.ArtikelID AND u.GrLan = ArtGroe.Groesse;

UPDATE TraeArti SET ArtGroeID = u.ArtGroeID
FROM TraeArti
JOIN @Update AS u ON u.TraeArtiID = TraeArti.ID;

UPDATE Teile SET ArtGroeID = TraeArti.ArtGroeID
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN @Update AS u on u.TraeArtiID = TraeArti.ID;

UPDATE Prod SET ArtGroeID = TraeArti.ArtGroeID
FROM Prod
JOIN TraeArti ON Prod.TraeArtiID = TraeArti.ID
JOIN @Update AS u ON u.TraeArtiID = TraeArti.ID;