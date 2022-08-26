DROP TABLE IF EXISTS #ArtiMap, #TeileMap;

GO

CREATE TABLE #ArtiMap (
  AltArtikelID int,
  NeuArtikelID int
);

CREATE TABLE #TeileMap (
  TeileID int PRIMARY KEY,
  TraegerID int,
  TraeArtiID int,
  KdArtiID int,
  ArtikelID int,
  ArtGroeID int,
  VsaID int
);

GO

INSERT INTO #ArtiMap (AltArtikelID, NeuArtikelID)
SELECT Artikel.ID, NeuArtikel.ID
FROM Artikel
JOIN Artikel AS NeuArtikel ON Artikel.ArtikelNr = NeuArtikel.ArtikelNr + N'E'
WHERE Artikel.ArtikelNr IN (N'04NP2E', N'05NP2E', N'06NP2E')

INSERT INTO #TeileMap (TeileID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, VsaID)
SELECT Teile.ID, Teile.TraegerID, -1, NeuKdArti.ID, NeuKdArti.ArtikelID, NeuArtGroe.ID, Teile.VsaID
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN #ArtiMap AS KdArtiMap ON KdArti.ArtikelID = KdArtiMap.AltArtikelID
JOIN KdArti AS NeuKdArti ON NeuKdArti.ArtikelID = KdArtiMap.NeuArtikelID AND NeuKdArti.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN #ArtiMap AS ArtGroeMap ON ArtGroe.ArtikelID = ArtGroeMap.AltArtikelID
JOIN ArtGroe AS NeuArtGroe ON NeuArtGroe.ArtikelID = ArtGroeMap.NeuArtikelID AND NeuArtGroe.Groesse = ArtGroe.Groesse
WHERE Kunden.KdNr = 218950
  AND Teile.Status = N'Q';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Neuen Trägerartikel anlegen                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO TraeArti (ID, VsaID, TraegerID, KdArtiID, ArtGroeID, UserID_, AnlageUserID_)
SELECT NEXT VALUE FOR NEXTID_TRAEARTI AS ID, TeileMap.VsaID, TeileMap.TraegerID, TeileMap.KdArtiID, TeileMap.ArtGroeID, @UserID, @UserID
FROM (
  SELECT DISTINCT tm.VsaID, tm.TraegerID, tm.KdArtiID, tm.ArtGroeID
  FROM #TeileMap AS tm
) TeileMap
WHERE NOT EXISTS (
  SELECT ta.*
  FROM TraeArti ta
  WHERE ta.VsaID = TeileMap.VsaID
    AND ta.TraegerID = TeileMap.TraegerID
    AND ta.KdArtiID = TeileMap.KdArtiID
    AND ta.ArtGroeID = TeileMap.ArtGroeID
);

UPDATE #TeileMap SET TraeArtiID = NeuTraeArti.ID
FROM TraeArti AS NeuTraeArti
WHERE NeuTraeArti.TraegerID = #TeileMap.TraegerID
  AND NeuTraeArti.KdArtiID = #TeileMap.KdArtiID
  AND NeuTraeArti.ArtGroeID = #TeileMap.ArtGroeID;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile updaten                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE Teile SET TraeArtiID = TeileMap.TraeArtiID, KdArtiID = TeileMap.KdArtiID, ArtikelID = TeileMap.ArtikelID, ArtGroeID = TeileMap.ArtGroeID
FROM #TeileMap AS TeileMap
WHERE TeileMap.TeileID = Teile.ID;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Hinweis einfügen                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO Hinweis (ID, TeileID, Aktiv, StatusSDC, Hinweis, BisWoche, Anzahl, EingabeDatum, HinwTextID, EingabeMitarbeiID, Patchen, AnlageUserID_, UserID_)
SELECT NEXT VALUE FOR NEXTID_HINWEIS AS ID, TeileMap.TeileID, CAST(1 AS bit), N'A', N'<l>Artikeldaten-Wechsel, bitte umpatchen  (' + AltArtikel.ArtikelNr + N' => ' + NeuArtikel.ArtikelNr + N')', N'2099/52', 1, GETDATE(), 999993, @UserID, CAST(1 AS bit), @UserID, @UserID 
FROM #TeileMap AS TeileMap
JOIN #ArtiMap AS ArtiMap ON TeileMap.ArtikelID = ArtiMap.NeuArtikelID
JOIN Artikel AS AltArtikel ON ArtiMap.AltArtikelID = AltArtikel.ID
JOIN Artikel AS NeuArtikel ON ArtiMap.NeuArtikelID = NeuArtikel.ID;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Applikationen                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @KdArApplAutoModus ADVINTEGERLIST;

INSERT INTO TraeAppl (ID, TraeArtiID, ApplKdArtiID, ArtiTypeID, Mass, PlatzID, KdArApplID, UserID_, AnlageUserID_)
SELECT NEXT VALUE FOR NEXTID_TRAEAPPL AS ID, MissingTraeAppl.TraeArtiID, MissingTraeAppl.ApplKdArtiID, MissingTraeAppl.ArtiTypeID, MissingTraeAppl.Mass, MissingTraeAppl.PlatzID, MissingTraeAppl.KdArApplID, @UserID, @UserID
FROM (
  SELECT DISTINCT f.TraeArtiID, f.ApplKdArtiID, f.ArtiTypeID, f.Mass, f.PlatzID, f.KdArApplID
  FROM #TeileMap AS TeileMap
  CROSS APPLY dbo.advFunc_GetMissingAppl(-1, TeileMap.TraeArtiID, -1, @KdArApplAutoModus, N'INSERT TRAEAPPL') AS f
) AS MissingTraeAppl;

UPDATE TeilAppl SET TeilAppl.TraeApplID = TraeAppl.ID
FROM TraeAppl, Teile
WHERE TeilAppl.TeileID = Teile.ID
  AND TraeAppl.PlatzID = TeilAppl.PlatzID
  AND TraeAppl.TraeArtiID = Teile.TraeArtiID
  AND TraeAppl.ApplKdArtiID = TeilAppl.ApplKdArtiID
  AND TeilAppl.TraeApplID != TraeAppl.ID
  AND Teile.ID IN (
    SELECT TeileID
    FROM #TeileMap
    );

GO