DECLARE @ErrorMessages TABLE (
  ErrorMessage nvarchar(200)
);

DECLARE @KundenID int = $ID$;
DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = $ENDDATE$;
DECLARE @RwConfigID int = (SELECT RwPoolTeileConfigID FROM Kunden WHERE ID = @KundenID);
DECLARE @RwArt int = 1;
DECLARE @RwBerechnungsVar int = (SELECT RwBerechnungsVar FROM RwConfig WHERE ID = @RwConfigID);
DECLARE @ArtiMaxWaschNull int = 0;
DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @Error bit = 0;

IF @RwConfigID <= 0 BEGIN
  SET @Error = 1;

  INSERT INTO @ErrorMessages
  SELECT N'Kunde ohne Pool-Restwertkonfiguration: ' + RTRIM(CAST(Kunden.KdNr AS nchar(10))) + N' - ' + RTRIM(Kunden.SuchCode) AS ErrorMessage
  FROM Kunden
  WHERE Kunden.ID = @KundenID;
END;

IF @RwBerechnungsVar = 2 BEGIN
  SET @ArtiMaxWaschNull = (
    SELECT COUNT(Artikel.ID)
    FROM Artikel
    JOIN EinzTeil ON EinzTeil.ArtikelID = Artikel.ID
    JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
    WHERE Vsa.KundenID = @KundenID
      AND EinzTeil.Status IN (N'Q', N'W')
      AND EinzTeil.RechPoID < 0
      AND Artikel.MaxWaschen = 0
  );

  IF @ArtiMaxWaschNull > 0
  BEGIN
    SET @Error = 1;

    INSERT INTO @ErrorMessages
    SELECT N'Artikel ohne definierter Anzahl an maximalen Wäschen: ' + RTRIM(x.ArtikelNr) + N' - ' + RTRIM(x.ArtikelBez) AS ErrorMessage
    FROM (
      SELECT DISTINCT Artikel.ArtikelNr, Artikel.ArtikelBez
      FROM Artikel
      JOIN EinzTeil ON EinzTeil.ArtikelID = Artikel.ID
      JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @KundenID
        AND EinzTeil.Status IN (N'A', N'Q', N'W')
        AND EinzTeil.RechPoID < 0
        AND Artikel.MaxWaschen = 0
    ) x;
  END;
END;

DROP TABLE IF EXISTS #TmpSchwund;

IF @Error = 1 BEGIN
  SELECT * FROM @ErrorMessages
END ELSE BEGIN
  WITH VsaStatus AS (
    SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
    FROM [Status]
    WHERE [Status].Tabelle = UPPER(N'VSA')
  )
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, VsaStatus.StatusBez AS VsaStatus, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Bereich.BereichBez$LAN$ AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS Vertragsbestand, 0 AS SchwundZeitraum, 0 AS SchwundAlt, 0 AS BereitsSchwundmarkiertZeitraum, 0 AS BereitsSchwundmarkiertAlt, 0 AS BereitsSchwundmarkiertNeu, 0 AS SchwundGesperrt, 0 AS Durchschnittsliefermenge, CAST(0 AS money) AS RestwertSchwundZeitraum, CAST(0 AS money) AS RestwertBereitsSchwund, Artikel.EKPreis, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID
  INTO #TmpSchwund
  FROM EinzTeil
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN VsaStatus ON Vsa.[Status] = VsaStatus.[Status]
  WHERE Kunden.ID = @KundenID
    AND Artikel.EAN IS NOT NULL
  GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, VsaStatus.StatusBez, Vsa.SuchCode, Vsa.Bez, Bereich.BereichBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, Vsa.ID, Artikel.ID, ArtGroe.ID;

  UPDATE Schwund SET Schwund.Vertragsbestand = x.Bestand, Schwund.Durchschnittsliefermenge = x.Durchschnitt
  FROM #TmpSchwund AS Schwund, (
    SELECT VsaAnf.Bestand, VsaAnf.Durchschnitt, VsaAnf.VsaID, KdArti.ArtikelID
    FROM VsaAnf, KdArti
    WHERE VsaAnf.KdArtiID = KdArti.ID
      AND VsaAnf.VsaID IN (SELECT VsaID FROM #TmpSchwund)
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtikelID = Schwund.ArtikelID;

  UPDATE Schwund SET Schwund.SchwundZeitraum = x.Anzahl, Schwund.RestwertSchwundZeitraum = x.Restwert
  FROM #TmpSchwund AS Schwund, (
    SELECT EinzTeil.VsaID, EinzTeil.ArtGroeID, COUNT(EinzTeil.ID) AS Anzahl, SUM(RestwertOP.RestwertInfo) AS Restwert
    FROM EinzTeil
    CROSS APPLY funcGetRestwertOP(EinzTeil.ID, @Woche, @RwArt) AS RestwertOP
    WHERE EinzTeil.VsaID IN (SELECT VsaID FROM #TmpSchwund)
      AND EinzTeil.LastScanTime BETWEEN @von AND @bis
      AND EinzTeil.Status IN (N'A', N'Q')
      AND EinzTeil.LastActionsID IN (102, 120, 136)  -- Teile beim Kunden
    GROUP BY EinzTeil.VsaID, EinzTeil.ArtGroeID
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtGroeID = Schwund.ArtGroeID;

  UPDATE Schwund SET Schwund.SchwundAlt = x.Anzahl
  FROM #TmpSchwund AS Schwund, (
    SELECT EinzTeil.VsaID, EinzTeil.ArtGroeID, COUNT(EinzTeil.ID) AS Anzahl
    FROM EinzTeil
    WHERE EinzTeil.VsaID IN (SELECT VsaID FROM #TmpSchwund)
      AND EinzTeil.LastScanTime < @von
      AND EinzTeil.Status IN (N'A', N'Q')
      AND EinzTeil.LastActionsID IN (102, 120, 136)  -- Teile beim Kunden
    GROUP BY EinzTeil.VsaID, EinzTeil.ArtGroeID
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtGroeID = Schwund.ArtGroeID;

  UPDATE Schwund SET Schwund.BereitsSchwundmarkiertZeitraum = x.Anzahl, Schwund.RestwertBereitsSchwund = x.Restwert
  FROM #TmpSchwund AS Schwund, (
    SELECT EinzTeil.VsaID, EinzTeil.ArtGroeID, COUNT(EinzTeil.ID) AS Anzahl, SUM(RestwertOP.RestwertInfo) AS Restwert
    FROM EinzTeil
    CROSS APPLY funcGetRestwertOP(EinzTeil.ID, @Woche, @RwArt) AS RestwertOP
    WHERE EinzTeil.VsaID IN (SELECT VsaID FROM #TmpSchwund)
      AND EinzTeil.Status = N'W'
      AND EinzTeil.RechPoID = -1
      AND EinzTeil.LastScanTime BETWEEN @von AND @bis
    GROUP BY EinzTeil.VsaID, EinzTeil.ArtGroeID
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtGroeID = Schwund.ArtGroeID;

  UPDATE Schwund SET Schwund.BereitsSchwundmarkiertAlt = x.Anzahl
  FROM #TmpSchwund AS Schwund, (
    SELECT EinzTeil.VsaID, EinzTeil.ArtGroeID, COUNT(EinzTeil.ID) AS Anzahl
    FROM EinzTeil
    WHERE EinzTeil.VsaID IN (SELECT VsaID FROM #TmpSchwund)
      AND EinzTeil.Status = N'W'
      AND EinzTeil.RechPoID = -1
      AND EinzTeil.LastScanTime < @von
    GROUP BY EinzTeil.VsaID, EinzTeil.ArtGroeID
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtGroeID = Schwund.ArtGroeID;

  UPDATE Schwund SET Schwund.BereitsSchwundmarkiertNeu = x.Anzahl
  FROM #TmpSchwund AS Schwund, (
    SELECT EinzTeil.VsaID, EinzTeil.ArtGroeID, COUNT(EinzTeil.ID) AS Anzahl
    FROM EinzTeil
    WHERE EinzTeil.VsaID IN (SELECT VsaID FROM #TmpSchwund)
      AND EinzTeil.Status = 'NW'
      AND EinzTeil.RechPoID = -1
      AND EinzTeil.LastScanTime > @bis
    GROUP BY EinzTeil.VsaID, EinzTeil.ArtGroeID
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtGroeID = Schwund.ArtGroeID;

  UPDATE Schwund SET Schwund.SchwundGesperrt = x.Anzahl
  FROM #TmpSchwund AS Schwund, (
    SELECT EinzTeil.VsaID, EinzTeil.ArtGroeID, COUNT(EinzTeil.ID) AS Anzahl
    FROM EinzTeil
    WHERE EinzTeil.VsaID IN (SELECT VsaID FROM #TmpSchwund)
      AND EinzTeil.Status = N'W'
      AND EinzTeil.RechPoID = -2
    GROUP BY EinzTeil.VsaID, EinzTeil.ArtGroeID
  ) AS x
  WHERE x.VsaID = Schwund.VsaID
    AND x.ArtGroeID = Schwund.ArtGroeID;

  SELECT KdNr, Kunde, VsaNr, VsaStatus, VsaStichwort, Vsa, Produktbereich, ArtikelNr, Artikelbezeichnung, Durchschnittsliefermenge, Vertragsbestand, SchwundZeitraum, SchwundAlt, BereitsSchwundmarkiertZeitraum, BereitsSchwundmarkiertAlt, BereitsSchwundmarkiertNeu, SchwundGesperrt AS SchwundVerrechnungGesperrt, SchwundZeitraum + BereitsSchwundmarkiertZeitraum AS SchwundVerrechnen, RestwertSchwundZeitraum + RestwertBereitsSchwund AS RestwertVerrechnen, EKPreis AS [EK aktuell], EKPreis * (SchwundZeitraum + BereitsSchwundmarkiertZeitraum) AS Wiederbeschaffungswert
  FROM #TmpSchwund
  WHERE Vertragsbestand > 0
    OR SchwundZeitraum > 0
    OR SchwundAlt > 0
    OR BereitsSchwundmarkiertZeitraum > 0
    OR BereitsSchwundmarkiertAlt > 0
    OR BereitsSchwundmarkiertNeu > 0
  ORDER BY KdNr, VsaNr, ArtikelNr;
END;