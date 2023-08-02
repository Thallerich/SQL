SELECT ArtiKomp.ID AS ArtiKompID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtiKomp.ArtGroeID, ArtGroe.Groesse AS Größe, ArtiRel.ArtiRelBez AS Relation, KompArtikel.ArtikelNr AS [ArtikelNr kompatibler Artikel], KompArtikel.ArtikelBez AS [Artikelbezeichnung kompatibler Artikel], ArtiKomp.KompArtGroeID, KompArtGroe.Groesse AS [Größe kompatibler Artikel], ISNULL(AnlageUser.UserName, N'') + ISNULL(N' (' + AnlageUser.Name + N')', N'') AS AnlageUser, ISNULL(UpdateUser.UserName, N'') + ISNULL(N' (' + UpdateUser.Name + N')', N'') AS UpdateUser
FROM ArtiKomp
JOIN ArtiRel ON ArtiKomp.ArtiRelID = ArtiRel.ID
JOIN Artikel ON ArtiKomp.ArtikelID = Artikel.ID
LEFT JOIN ArtGroe ON ArtiKomp.ArtGroeID = ArtGroe.ID ANd ArtiKomp.ArtikelID = ArtGroe.ArtikelID
JOIN Artikel AS KompArtikel ON ArtiKomp.KompArtikelID = KompArtikel.ID
LEFT JOIN ArtGroe AS KompArtGroe ON ArtiKomp.KompArtGroeID = KompArtGroe.ID ANd ArtiKomp.KompArtikelID = KompArtGroe.ArtikelID
JOIN Mitarbei AS UpdateUser ON ArtiKomp.UserID_ = UpdateUser.ID
JOIN Mitarbei AS AnlageUser ON ArtiKomp.AnlageUserID_ = AnlageUser.ID
WHERE (ArtiKomp.ArtGroeID < 0 OR ArtiKomp.KompArtGroeID < 0);

GO

SELECT ArtiKomp.ID AS ArtiKompID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtiKomp.ArtGroeID, ArtGroe.Groesse AS Größe, ArtiRel.ArtiRelBez AS Relation, KompArtikel.ArtikelNr AS [ArtikelNr kompatibler Artikel], KompArtikel.ArtikelBez AS [Artikelbezeichnung kompatibler Artikel], ArtiKomp.KompArtGroeID, KompArtGroe.Groesse AS [Größe kompatibler Artikel], ISNULL(AnlageUser.UserName, N'') + ISNULL(N' (' + AnlageUser.Name + N')', N'') AS AnlageUser, ISNULL(UpdateUser.UserName, N'') + ISNULL(N' (' + UpdateUser.Name + N')', N'') AS UpdateUser
FROM ArtiKomp
JOIN ArtiRel ON ArtiKomp.ArtiRelID = ArtiRel.ID
JOIN Artikel ON ArtiKomp.ArtikelID = Artikel.ID
LEFT JOIN ArtGroe ON ArtiKomp.ArtGroeID = ArtGroe.ID ANd ArtiKomp.ArtikelID = ArtGroe.ArtikelID
JOIN Artikel AS KompArtikel ON ArtiKomp.KompArtikelID = KompArtikel.ID
LEFT JOIN ArtGroe AS KompArtGroe ON ArtiKomp.KompArtGroeID = KompArtGroe.ID ANd ArtiKomp.KompArtikelID = KompArtGroe.ArtikelID
JOIN Mitarbei AS UpdateUser ON ArtiKomp.UserID_ = UpdateUser.ID
JOIN Mitarbei AS AnlageUser ON ArtiKomp.AnlageUserID_ = AnlageUser.ID
WHERE (ArtGroe.ID IS NULL OR KompArtGroe.ID IS NULL);

GO

SELECT ArtiKomp.ID AS ArtiKompID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtiKomp.ArtGroeID, ArtGroe.Groesse AS Größe, ArtiRel.ArtiRelBez AS Relation, KompArtikel.ArtikelNr AS [ArtikelNr kompatibler Artikel], KompArtikel.ArtikelBez AS [Artikelbezeichnung kompatibler Artikel], ArtiKomp.KompArtGroeID, KompArtGroe.Groesse AS [Größe kompatibler Artikel], ISNULL(AnlageUser.UserName, N'') + ISNULL(N' (' + AnlageUser.Name + N')', N'') AS AnlageUser, ISNULL(UpdateUser.UserName, N'') + ISNULL(N' (' + UpdateUser.Name + N')', N'') AS UpdateUser
FROM ArtiKomp
JOIN ArtiRel ON ArtiKomp.ArtiRelID = ArtiRel.ID
JOIN Artikel ON ArtiKomp.ArtikelID = Artikel.ID
LEFT JOIN ArtGroe ON ArtiKomp.ArtGroeID = ArtGroe.ID ANd ArtiKomp.ArtikelID = ArtGroe.ArtikelID
JOIN Artikel AS KompArtikel ON ArtiKomp.KompArtikelID = KompArtikel.ID
LEFT JOIN ArtGroe AS KompArtGroe ON ArtiKomp.KompArtGroeID = KompArtGroe.ID ANd ArtiKomp.KompArtikelID = KompArtGroe.ArtikelID
JOIN Mitarbei AS UpdateUser ON ArtiKomp.UserID_ = UpdateUser.ID
JOIN Mitarbei AS AnlageUser ON ArtiKomp.AnlageUserID_ = AnlageUser.ID
WHERE ArtGroe.ArtikelID = KompArtGroe.ArtikelID;

GO