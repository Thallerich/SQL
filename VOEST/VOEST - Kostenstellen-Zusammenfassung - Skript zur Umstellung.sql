DROP TABLE IF EXISTS #AbteilCombine;
DROP TABLE IF EXISTS #LsPoCombine;
GO

SELECT Abteil.ID AS AbteilID_Old,
  CAST(NULL AS int) AS AbteilID_Neu,
  [Kostenstelle neu] = Abteil.Bez,
  Abteil.Code,
  Abteil.KundenID
INTO #AbteilCombine
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Kunden.KdNr IN (272376, 271583, 272353, 272643)
  AND (Abteil.Bez = '-' OR TRY_CAST(Abteil.Bez AS bigint) IS NOT NULL);

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

DECLARE @AbteilNew TABLE (
  AbteilID int,
  Abteilung nvarchar(20) COLLATE Latin1_General_CS_AS
);

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE Abteil SET Abteilung = Abteil.Abteilung + N'***'
    FROM (
      SELECT DISTINCT KundenID, [Kostenstelle neu] AS Abteilung
      FROM #AbteilCombine
    ) AS x
    WHERE x.KundenID = Abteil.KundenID
      AND x.Abteilung = Abteil.Abteilung
      AND Abteil.[Status] = 'I';
  
    INSERT INTO Abteil (KundenID, Abteilung, Bez, [Status], Code, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Abteilung
    INTO @AbteilNew
    SELECT DISTINCT KundenID, [Kostenstelle neu] AS Abteilung, [Kostenstelle neu] AS Bez, N'A' AS [Status], Code, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #AbteilCombine
    WHERE NOT EXISTS (
      SELECT Abteil.*
      FROM Abteil
      WHERE Abteil.KundenID = #AbteilCombine.KundenID
        AND Abteil.Abteilung = #AbteilCombine.[Kostenstelle neu]
    );

    UPDATE #AbteilCombine SET AbteilID_Neu = [@AbteilNew].AbteilID
    FROM @AbteilNew
    WHERE [@AbteilNew].Abteilung = #AbteilCombine.[Kostenstelle neu];

    UPDATE Traeger SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE Traeger.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE Vsa SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE Vsa.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE VsaLeas SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE VsaLeas.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE Schrank SET Schrank.AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE Schrank.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE VsaAnf SET VsaAnf.AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE VsaAnf.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE Abteil SET [Status] = 'I', UserID_ = @userid
    FROM #AbteilCombine
    WHERE Abteil.ID = #AbteilCombine.AbteilID_Old;

    /* Lieferschein-Positionen - Start */

    SELECT LsPo.LsKoID, SUM(LsPo.Menge) AS Menge, SUM(LsPo.MengeZurueck) AS MengeZurueck, SUM(LsPo.MengeReserviert) AS MengeReserviert, SUM(LsPo.MengeEntnommen) AS MengeEntnommen, SUM(LsPo.UrMenge) AS UrMenge, SUM(LsPo.NachLief) AS NachLief, LsPo.EPreis, SUM(LsPo.FehlMenge) AS FehlMenge, LsPo.EPreisRech, LsPo.WaeKursID, LsPo.ProduktionID, LsPo.GrundNoServiceID, LsPo.InternKalkPreis, #AbteilCombine.AbteilID_Neu, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID, LsPo.TraegerID, STRING_AGG(CAST(LsPo.ID AS nvarchar), ',') AS LsPoIDs, COUNT(LsPo.ID) AS AnzLsPos, CAST(NULL AS bigint) AS LsPoID_Neu, ROW_NUMBER() OVER (ORDER BY LsKoID ASC) AS Rownumber
    INTO #LsPoCombine
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    JOIN Abteil ON LsPo.AbteilID = Abteil.ID
    JOIN #AbteilCombine ON Abteil.ID = #AbteilCombine.AbteilID_Old
    WHERE LsKo.[Status] < 'W'
      AND Abteil.[Status] = 'I'
      AND LsPo.RechPoID = -1
      AND LsKo.VsaID IN (
        SELECT Vsa.ID
        FROM Vsa
        WHERE Vsa.KundenID IN (
          SELECT #AbteilCombine.KundenID
          FROM #AbteilCombine
        )
      )
    GROUP BY LsPo.LsKoID, LsPo.EPreis, LsPo.EPreisRech, LsPo.WaeKursID, LsPo.ProduktionID, LsPo.GrundNoServiceID, LsPo.InternKalkPreis, #AbteilCombine.AbteilID_Neu, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID, LsPo.TraegerID;

    UPDATE LsPo SET AbteilID = #LsPoCombine.AbteilID_Neu, UserID_ = @userid
    FROM #LsPoCombine
    JOIN #AbteilCombine ON #LsPoCombine.AbteilID_Neu = #AbteilCombine.AbteilID_Neu
    WHERE #LsPoCombine.AnzLsPos = 1
      AND LsPo.LsKoID = #LsPoCombine.LsKoID
      AND LsPo.AbteilID = #AbteilCombine.AbteilID_Old
      AND LsPo.KdArtiID = #LsPoCombine.KdArtiID
      AND LsPo.Kostenlos = #LsPoCombine.Kostenlos
      AND LsPo.ArtGroeID = #LsPoCombine.ArtGroeID
      AND LsPo.VsaOrtID = #LsPoCombine.VsaOrtID
      AND LsPo.LagerOrtID = #LsPoCombine.LagerOrtID
      AND LsPo.LsKoGruID = #LsPoCombine.LsKoGruID
      AND LsPo.VpsKoID = #LsPoCombine.VpsKoID
      AND LsPo.TraegerID = #LsPoCombine.TraegerID;

    DECLARE NewLsPo CURSOR FOR
      SELECT Rownumber, LsPoIDs
      FROM #LsPoCombine
      WHERE AnzLsPos > 1
        AND LsPoID_Neu IS NULL;

    OPEN NewLsPo;

    DECLARE @rownumber int, @newlspoid bigint;
    DECLARE @lspoids nvarchar(max), @sqltext nvarchar(max);
    DECLARE @LsPo TABLE (LsPoID int);

    FETCH NEXT FROM NewLsPo INTO @rownumber, @lspoids;
      
    WHILE @@FETCH_STATUS = 0
    BEGIN
      INSERT INTO LsPo (LsKoID, Menge, MengeZurueck, MengeReserviert, MengeEntnommen, UrMenge, NachLief, EPreis, FehlMenge, EPreisRech, WaeKursID, ProduktionID, GrundNoServiceID, InternKalkPreis, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, LagerOrtID, LsKoGruID, VpsKoID, TraegerID, AnlageUserID_, UserID_)
      OUTPUT inserted.ID INTO @LsPo (LsPoID)
      SELECT LsKoID, Menge, MengeZurueck, MengeReserviert, MengeEntnommen, UrMenge, NachLief, EPreis, FehlMenge, EPreisRech, WaeKursID, ProduktionID, GrundNoServiceID, InternKalkPreis, AbteilID_Neu, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, LagerOrtID, LsKoGruID, VpsKoID, TraegerID, @userid AS AnlageUserID_, @userid AS UserID_
      FROM #LsPoCombine
      WHERE #LsPoCombine.Rownumber = @rownumber;

      SELECT @newlspoid = LsPoID FROM @LsPo;
      UPDATE #LsPoCombine SET LsPoID_Neu = @newlspoid;

      SET @sqltext = '
        UPDATE Scans SET LsPoID = ' + CAST(@newlspoid AS nvarchar) + ', UserID_ = ' + CAST(@userid AS nvarchar) + ' WHERE LsPoID IN (' + @lspoids + ');
        UPDATE EinzHist SET LastLsPoID = ' + CAST(@newlspoid AS nvarchar) + ', UserID_ = ' + CAST(@userid AS nvarchar) + ' WHERE LastLsPoID IN (' + @lspoids + ');
      ';

      EXEC sp_executesql @sqltext;

      SET @sqltext = '
        DELETE FROM LsPo WHERE ID IN (' + @lspoids + ');
      ';

      EXEC sp_executesql @sqltext;

      FETCH NEXT FROM NewLsPo INTO @rownumber, @lspoids;
    END;

    CLOSE NewLsPo;
    DEALLOCATE NewLsPo;

    /* Lieferschein-Positionen - Ende */
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */



