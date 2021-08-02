/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Neue Größe existiert nicht                                                                                                ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, __sizechange.Aenderung, LEFT(__sizechange.Groesse, CHARINDEX(N'/', __sizechange.Groesse, 1) - 1) + N'/' + RIGHT(REPLICATE(N'0', 3) + RTRIM(__sizechange.Aenderung), 3) AS NewSize, NewArtGroe.ID AS NewArtGroeID
FROM __sizechange
JOIN Artikel ON __sizechange.ArtikelNr = Artikel.ArtikelNr
JOIN ArtGroe ON __sizechange.Groesse = ArtGroe.Groesse AND Artikel.ID = ArtGroe.ArtikelID
LEFT JOIN ArtGroe AS NewArtGroe ON LEFT(__sizechange.Groesse, CHARINDEX(N'/', __sizechange.Groesse, 1) - 1) + N'/' + RIGHT(REPLICATE(N'0', 3) + RTRIM(__sizechange.Aenderung), 3) = NewArtGroe.Groesse AND Artikel.ID = NewArtGroe.ArtikelID
JOIN TraeArti ON ArtGroe.ID = TraeArti.ArtGroeID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID AND __sizechange.TraegerNr = Traeger.Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID AND __sizechange.VsaNr = Vsa.VsaNr
JOIN Kunden ON Vsa.KundenID = Kunden.ID AND __sizechange.KdNr = Kunden.KdNr
WHERE CHARINDEX(N'/', __sizechange.Groesse) > 0
  AND NewArtGroe.ID IS NULL; */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Map auf neue Größe                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF OBJECT_ID(N'__SizeChangeIT49847') IS NOT NULL
  TRUNCATE TABLE __SizeChangeIT49847;
ELSE
  CREATE TABLE __SizeChangeIT49847 (
    VsaID int,
    TraegerID int,
    KdArtiID int,
    OldArtGroeID int,
    NewArtGroeID int,
    OldTraeArtiID int,
    NewTraeArtiID int,
    FolgeTraeArtiID int,
    FolgeArtZwingend bit
  );

GO

--SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, __sizechange.Aenderung, LEFT(__sizechange.Groesse, CHARINDEX(N'/', __sizechange.Groesse, 1) - 1) + N'/' + RIGHT(REPLICATE(N'0', 3) + RTRIM(__sizechange.Aenderung), 3) AS NewSize, NewArtGroe.ID AS NewArtGroeID
INSERT INTO __SizeChangeIT49847 (VsaID, TraegerID, OldArtGroeID, NewArtGroeID, KdArtiID, OldTraeArtiID, FolgeTraeArtiID, FolgeArtZwingend)
SELECT Vsa.ID AS VsaID, Traeger.ID AS TraegerID, ArtGroe.ID AS OldArtGroeID, NewArtGroe.ID AS NewArtGroeID, TraeArti.KdArtiID, TraeArti.ID AS OldTraeArtiID, TraeArti.FolgeTraeArtiID, TraeArti.FolgeArtZwingend
FROM __sizechange
JOIN Artikel ON __sizechange.ArtikelNr = Artikel.ArtikelNr
JOIN ArtGroe ON __sizechange.Groesse = ArtGroe.Groesse AND Artikel.ID = ArtGroe.ArtikelID
LEFT JOIN ArtGroe AS NewArtGroe ON LEFT(__sizechange.Groesse, CHARINDEX(N'/', __sizechange.Groesse, 1) - 1) + N'/' + RIGHT(REPLICATE(N'0', 3) + RTRIM(__sizechange.Aenderung), 3) = NewArtGroe.Groesse AND Artikel.ID = NewArtGroe.ArtikelID
JOIN TraeArti ON ArtGroe.ID = TraeArti.ArtGroeID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID AND __sizechange.TraegerNr = Traeger.Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID AND __sizechange.VsaNr = Vsa.VsaNr
JOIN Kunden ON Vsa.KundenID = Kunden.ID AND __sizechange.KdNr = Kunden.KdNr
WHERE CHARINDEX(N'/', __sizechange.Groesse) > 0
  AND NewArtGroe.ID IS NOT NULL;

GO

DECLARE @NewTraeArti TABLE (
  TraeArtiID int,
  TraegerID int,
  KdArtiID int,
  ArtGroeID int
);

INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, FolgeTraeArtiID, FolgeArtZwingend)
OUTPUT inserted.ID, inserted.TraegerID, inserted.KdArtiID, inserted.ArtGroeID
INTO @NewTraeArti (TraeArtiID, TraegerID, KdArtiID, ArtGroeID)
SELECT DISTINCT VsaID, TraegerID, NewArtGroeID, KdArtiID, FolgeTraeArtiID, FolgeArtZwingend
FROM __SizeChangeIT49847
WHERE NOT EXISTS (
  SELECT TA.*
  FROM TraeArti TA
  WHERE TA.TraegerID = __SizeChangeIT49847.TraegerID
    AND TA.KdArtiID = __SizeChangeIT49847.KdArtiID
    AND TA.ArtGroeID = __SizeChangeIT49847.NewArtGroeID
);

UPDATE __SizeChangeIT49847 SET NewTraeArtiID = NewTraeArti.TraeArtiID
FROM __SizeChangeIT49847
JOIN @NewTraeArti AS NewTraeArti ON NewTraeArti.TraegerID = __SizeChangeIT49847.TraegerID AND NewTraeArti.KdArtiID = __SizeChangeIT49847.KdArtiID AND NewTraeArti.ArtGroeID = __SizeChangeIT49847.NewArtGroeID;

UPDATE __SizeChangeIT49847 SET NewTraeArtiID = TraeArti.ID
FROM __SizeChangeIT49847
JOIN TraeArti ON TraeArti.TraegerID = __SizeChangeIT49847.TraegerID AND TraeArti.KdArtiID = __SizeChangeIT49847.KdArtiID AND TraeArti.ArtGroeID = __SizeChangeIT49847.NewArtGroeID
WHERE __SizeChangeIT49847.NewTraeArtiID IS NULL;

GO

IF (SELECT COUNT(*) FROM __SizeChangeIT49847 WHERE NewTraeArtiID IS NULL) > 0 PRINT(N'Not all work has been done!')
ELSE PRINT(N'We''re good to go!');

SELECT N'ABSCHAFFEN;TRAEARTI;' + CAST(OldTraeArtiID AS nvarchar) + N';' + CAST(NewTraeArtiID AS nvarchar) + N';1' AS ModuleCall
FROM __SizeChangeIT49847
WHERE OldTraeArtiID != NewTraeArtiID;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile.ArtGroeID korrigieren                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE Teile SET ArtGroeID = TraeArti.ArtGroeID
FROM TraeArti
WHERE TraeArti.ID = Teile.TraeArtiID
  AND TraeArti.ArtGroeID != Teile.ArtGroeID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Änderungen löschen                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DELETE FROM TraeAppl
WHERE ID IN (
  SELECT TraeAppl.ID
  FROM __SizeChangeIT49847
  JOIN TraeArti ON __SizeChangeIT49847.NewTraeArtiID = TraeArti.ID
  JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
  JOIN TraeAppl ON TraeAppl.TraeArtiID = TraeArti.ID
  JOIN KdArti ON TraeAppl.ApplKdArtiID = KdArti.ID
  WHERE KdArti.ArtikelID IN (3806701, 3806724, 3806737, 3806738)
    AND TraeAppl.Mass = SUBSTRING(ArtGroe.Groesse, CHARINDEX(N'/', ArtGroe.Groesse, 1) + 1, LEN(ArtGroe.Groesse) - CHARINDEX(N'/', ArtGroe.Groesse, 1))
);

DELETE FROM TeilAppl
WHERE ID IN (
  SELECT TeilAppl.ID
  FROM __SizeChangeIT49847
  JOIN Teile ON Teile.TraeArtiID = __SizeChangeIT49847.NewTraeArtiID
  JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
  JOIN TeilAppl ON TeilAppl.TeileID = Teile.ID
  JOIN KdArti ON TeilAppl.ApplKdArtiID = KdArti.ID
  WHERE KdArti.ArtikelID IN (3806701, 3806724, 3806737, 3806738)
    AND TeilAppl.Mass != SUBSTRING(ArtGroe.Groesse, CHARINDEX(N'/', ArtGroe.Groesse, 1) + 1, LEN(ArtGroe.Groesse) - CHARINDEX(N'/', ArtGroe.Groesse, 1))
);