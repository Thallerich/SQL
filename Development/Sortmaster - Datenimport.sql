IF @@SERVERNAME != N'SVATSAWRSQL1'
BEGIN
  RAISERROR('This script can only be executed on the server SVATSAWRSQL1.', 16, 1);
END
ELSE
BEGIN
  DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  /* ++ Cleanup                                                                                                                   ++ */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

  DELETE FROM WascSoPr WHERE WascSortID > 0
  DELETE FROM WascSort WHERE ID > 0;

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  /* ++ Import "Waschsortierungen"                                                                                                ++ */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

  WITH Waschsort AS (
    SELECT DISTINCT __Sortmaster.Waschsortierung
    FROM [SALADVPSQLC1A1.salres.com].Salesianer.dbo.__Sortmaster
    WHERE __Sortmaster.Waschsortierung IS NOT NULL
      AND __Sortmaster.Waschsortierung != 0
  )
  INSERT INTO Salesianer_SAWR.dbo.WascSort (Waschsortierung, WascSortBez, Code, AnlageUserID_, UserID_)
  SELECT WaschSort.Waschsortierung,
    WaschSortBez = (
      SELECT TOP 1 Sortmaster.[Waschsortierung-Bez]
      FROM (
        SELECT __Sortmaster.Waschsortierung, __Sortmaster.[Waschsortierung-Bez], COUNT(*) AS Anzahl
        FROM [SALADVPSQLC1A1.salres.com].Salesianer.dbo.__Sortmaster
        GROUP BY __Sortmaster.Waschsortierung, __Sortmaster.[Waschsortierung-Bez]
      ) AS Sortmaster
      WHERE Sortmaster.Waschsortierung = Waschsort.Waschsortierung
      ORDER BY Sortmaster.Anzahl DESC
    ),
    CAST(WaschSort.Waschsortierung AS nvarchar),
    @userid,
    @userid
  FROM WaschSort;

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  /* ++ Import "Regelwerk"                                                                                                        ++ */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

  INSERT INTO Salesianer_SAWR.dbo.WascSoPr (KdArtiID, WascSortID, AnlageUserID_, UserID_)
  SELECT KdArti.ID AS KdArtiID, WascSort.ID, @userid, @userid
  FROM Salesianer_SAWR.dbo.KdArti
  JOIN Salesianer_SAWR.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Salesianer_SAWR.dbo.Kunden ON KdArti.KundenID = Kunden.ID
  JOIN [SALADVPSQLC1A1.salres.com].Salesianer.dbo.__Sortmaster ON Artikel.ArtikelNr = __Sortmaster.ArtikelNr AND KdArti.Variante = __Sortmaster.Variante AND Kunden.KdNr = __Sortmaster.KdNr
  JOIN Salesianer_SAWR.dbo.WascSort ON __Sortmaster.Waschsortierung = WascSort.Waschsortierung
  WHERE __Sortmaster.Waschsortierung IS NOT NULL
    AND __Sortmaster.Waschsortierung != 0;

END;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF @@SERVERNAME NOT IN (N'SALADVPSQLC1N1', N'SALADVPSQLC1N2')
BEGIN
  RAISERROR('This script can only be executed on the server SALADVPSQLC1A1.', 16, 1);
END
ELSE
BEGIN

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  /* ++ Import "Waschprogramme"                                                                                                   ++ */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

  SELECT KdArti.ID AS KdArtiID, WaschPrg.ID AS WaschPrgID
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN __Sortmaster ON Artikel.ArtikelNr = __Sortmaster.ArtikelNr AND KdArti.Variante = __Sortmaster.Variante AND Kunden.KdNr = __Sortmaster.KdNr
  JOIN WaschPrg ON CAST(__Sortmaster.Waschprogramm AS nvarchar) = WaschPrg.WaschPrg
  WHERE __Sortmaster.Waschprogramm IS NOT NULL
    AND __Sortmaster.Waschprogramm != 0;
END;

GO