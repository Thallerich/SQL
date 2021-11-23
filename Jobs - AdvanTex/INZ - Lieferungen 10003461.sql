DECLARE @curdate date = CAST(GETDATE() AS date);
DECLARE @kdnr int = 10003461;

DECLARE @sqltext nvarchar(max) =
  N'SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, LiefArt.LiefartBez AS Auslieferart, AnfPo.Angefordert, LsPo.Menge AS Geliefert, LsPo.Menge - AnfPo.Angefordert AS Differenz ' +
  N'FROM AnfPo ' +
  N'JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID ' +
  N'JOIN Vsa ON AnfKo.VsaID = Vsa.ID ' +
  N'JOIN Kunden ON Vsa.KundenID = Kunden.ID ' +
  N'JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID ' +
  N'JOIN Artikel ON KdArti.ArtikelID = Artikel.ID ' +
  N'JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID ' +
  N'JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID ' +
  N'JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID ' +
  N'LEFT JOIN LsPo ON LsPo.KdArtiID = AnfPo.KdArtiID AND LsPo.ArtGroeID = AnfPo.ArtGroeID AND LsPo.Kostenlos = AnfPo.Kostenlos AND LsPo.LsKoGruID = AnfPo.LsKoGruID AND LsPo.VpsKoID = AnfPo.VpsKoID AND LsPo.LsKoID = AnfKo.LsKoID ' +
  N'WHERE AnfKo.LieferDatum = CAST(GETDATE() AS date) ' +
  N'  AND Kunden.KdNr = @kdnr ' +
  N'  AND AnfKo.Status >= N''I''' +
  N'  AND (AnfPo.Angefordert <> 0 OR ISNULL(LsPo.Menge, 0) <> 0)';

EXEC sp_executesql @sqltext, N'@curdate date, @kdnr int', @curdate, @kdnr;