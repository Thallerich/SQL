DECLARE @pz nvarchar(20) = $2$, @ls int = TRY_CAST($1$ AS int), @contain varchar(33) = $3$;
DECLARE @sql nvarchar(max);

IF @ls > 0
BEGIN
  SET @sql = N'
  SELECT AnfKo.AuftragsNr, AnfKo.Lieferdatum, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, AnfPo.Angefordert, AnfPo.Geliefert, COUNT(DISTINCT Scans.EinzTeilID) AS [Anzahl gescannt in Container], Contain.Barcode AS Container
  FROM Scans
  JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
  JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Contain ON Scans.ContainID = Contain.ID
  WHERE LsKo.LsNr = @ls
  GROUP BY AnfKo.AuftragsNr, AnfKo.LieferDatum, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, AnfPo.Angefordert, AnfPo.Geliefert, Contain.Barcode
  ';

  EXEC sp_executesql @sql, N'@ls int', @ls;
END;

IF @pz != '' AND @ls <= 0
BEGIN
  SET @sql = N'
  SELECT AnfKo.AuftragsNr, AnfKo.Lieferdatum, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, AnfPo.Angefordert, AnfPo.Geliefert, COUNT(DISTINCT Scans.EinzTeilID) AS [Anzahl gescannt in Container], Contain.Barcode AS Container
  FROM Scans
  JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
  JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Contain ON Scans.ContainID = Contain.ID
  WHERE AnfKo.AuftragsNr = @pz
  GROUP BY AnfKo.AuftragsNr, AnfKo.LieferDatum, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, AnfPo.Angefordert, AnfPo.Geliefert, Contain.Barcode
  ';

  EXEC sp_executesql @sql, N'@pz nvarchar(20)', @pz;
END;

IF @contain != '' AND @ls <= 0 AND @pz = ''
BEGIN
  SET @sql = N'
  SELECT AnfKo.AuftragsNr, AnfKo.Lieferdatum, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, AnfPo.Angefordert, AnfPo.Geliefert, COUNT(DISTINCT Scans.EinzTeilID) AS [Anzahl gescannt in Container], Contain.Barcode AS Container
  FROM Scans
  JOIN AnfPo ON Scans.AnfPoID = AnfPo.ID
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
  JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Contain ON Scans.ContainID = Contain.ID
  WHERE Contain.Barcode = @contain
    AND AnfKo.Lieferdatum >= CAST(DATEADD(year, -1, GETDATE()) AS date)
  GROUP BY AnfKo.AuftragsNr, AnfKo.LieferDatum, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, AnfPo.Angefordert, AnfPo.Geliefert, Contain.Barcode
  ';

  EXEC sp_executesql @sql, N'@contain varchar(33)', @contain;
END;

IF @contain = '' AND @ls <= 0 AND @pz = ''
  SELECT N'Bitte einen Aufruf-Parameter eingeben!' AS Error;