DROP TABLE IF EXISTS #LagerteileHist_1401;
DROP TABLE IF EXISTS #Artikelanzahl_Lagerort_1401;
DROP TABLE IF EXISTS #Umlauf_Salesianer_1401;

DECLARE @LagerID int = $1$;
DECLARE @CurrentWeek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

CREATE TABLE #LagerteileHist_1401 ( 
  Barcode varchar(33) COLLATE Latin1_General_CS_AS,
  EinzHistID int,
  EinzteilID int,
  KundenID int,
  VsaID int,
  LagerortID int, 
  LagerartID int, 
  ArtikelID int,
  ArtGroeID int,  
  EKPreis money, 
  [Status] varchar(2) COLLATE Latin1_General_CS_AS,
  EinzHistVon date,
  RuecklaufG int
);
    
CREATE INDEX Ind_LagerortID ON #LagerteileHist_1401 (LagerortID);
CREATE INDEX Ind_ArtGroeID ON #LagerteileHist_1401 (ArtGroeID);
CREATE INDEX Ind_LagerartID ON #LagerteileHist_1401 (LagerartID);
    
INSERT INTO #LagerteileHist_1401 (Barcode, EinzHistID, EinzteilID, KundenID, VsaID, LagerortID, LagerartID, ArtikelID, ArtGroeID, EKPreis, [Status], EinzHistVon, RuecklaufG)
SELECT EinzHist.Barcode,
  EinzHist.ID,
  EinzHist.EinzTeilID,
  EinzHist.KundenID,
  IIF(EinzHist.TraegerID < 0, EinzHist.VsaID, Traeger.VsaID) AS VsaID,
  Lagerort.ID AS LagerortID, 
  EinzHist.LagerArtID,
  Artikel.ID AS ArtikelID,
  EinzHist.ArtGroeID, 
  ArtGroe.EKPreis, 
  Einzhist.Status,
  EinzHist.EinzHistVon,
  EinzTeil.RuecklaufG
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Lagerort ON EinzHist.LagerOrtID = LagerOrt.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
WHERE Lagerart.LagerID = @LagerID
  AND EinzHist.Status IN ('X', 'XE', 'XM')
  AND EinzHist.EinzHistTyp = 2;

CREATE TABLE #Umlauf_Salesianer_1401 (
  StandortID int,
  ArtGroeID int,
  ArtikelID int,
  Umlauf int
);

CREATE INDEX Ind_ArtikelID ON #Umlauf_Salesianer_1401 (ArtikelID)
CREATE INDEX Ind_ArtGroe ON #Umlauf_Salesianer_1401 (ArtgroeID)

INSERT INTO #Umlauf_Salesianer_1401 (StandortID, ArtGroeID, ArtikelID, Umlauf)
SELECT StandortID, ArtGroeID, ArtikelID, SUM(Umlauf) AS Umlauf 
FROM ( 
  SELECT IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID) AS StandortID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf 
  FROM VsaLeas 
  JOIN Vsa ON VsaLeas.VsaID = Vsa.ID 
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
  WHERE ISNULL(VsaLeas.Ausdienst, N'2099/52') > @CurrentWeek
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND VsaBer.[Status] = N'A'
    AND KdBer.[Status] = N'A'
  GROUP BY IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID), COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID 
  
  UNION ALL 
  
  SELECT IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID) AS StandortID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf 
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID 
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
  WHERE VsaAnf.Bestand != 0 AND VsaAnf.[Status] = N'A'
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND VsaBer.[Status] = N'A'
    AND KdBer.[Status] = N'A'
  GROUP BY IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID), COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID 
  
  UNION ALL 
  
  SELECT IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID) AS StandortID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf 
  FROM Strumpf
  JOIN Vsa ON Strumpf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID 
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
  WHERE Strumpf.[Status] != N'X' 
    AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek 
    AND Strumpf.WegGrundID < 0 
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND VsaBer.[Status] = N'A'
    AND KdBer.[Status] = N'A'
  GROUP BY IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID), COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID 
  
  UNION ALL 
  
  SELECT IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID) AS StandortID, TraeArti.ArtGroeID, KdArti.ArtikelID, IIF(TraeArti.MengeAufkauf > TraeArti.Menge, TraeArti.MengeAufkauf, TraeArti.Menge) AS Umlauf 
  FROM TraeArti 
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID 
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND VsaBer.[Status] = N'A'
    AND KdBer.[Status] = N'A'
    AND Traeger.[Status] != N'I'
  
  UNION ALL 
  
  SELECT IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID) AS StandortID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
  FROM TraeArti 
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID 
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID 
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID 
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND KdArAppl.ArtiTypeID = 3 --Emblem 
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND VsaBer.[Status] = N'A'
    AND KdBer.[Status] = N'A'
    AND Traeger.[Status] != N'I'
  
  UNION ALL 
  
  SELECT IIF(StandBer.LokalLagerID = -1, StandBer.LagerID, StandBer.LokalLagerID) AS StandortID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
  FROM TraeArti 
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID 
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID 
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID 
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
    AND Kunden.[Status] = N'A'
    AND Vsa.[Status] = N'A'
    AND VsaBer.[Status] = N'A'
    AND KdBer.[Status] = N'A'
    AND Traeger.[Status] != N'I'
) AS x 
GROUP BY StandortID, ArtGroeID, ArtikelID;
  
SELECT LagerteileHist.Barcode,
  IIF(Kunden.ID > 0, Kunden.KdNr, NULL) AS KdNr,
  IIF(Kunden.ID > 0, Kunden.SuchCode, NULL) as [Letzter Kunde],
  IIF(Vsa.ID > 0, Vsa.VsaNr, NULL) AS [letzte VsaNr],
  IIF(Vsa.ID > 0, Vsa.Bez, NULL) AS [letzte Vsa],
  LagerteileHist.RuecklaufG as [Anzahl Wäschen],
  LagerteileHist.EinzHistVon AS [im Lager seit],
  Standort.Bez AS Lagerstandort, 
  Lagerort.Lagerort, 
  LagSchr.Bez AS Lagerschrank, 
  Lagerart.LagerartBez$LAN$ AS Lagerart, 
  Lagerart.Zustand, 
  LagerArt.Neuwertig, 
  Artikel.ArtikelNr, 
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 
  ArtGroe.Groesse AS Größe,
  ArtikelverwendungStandort.VerwendetIn AS [verwendet in],
  Artikelstatus.StatusBez AS Artikelstatus, 
  Umlaufmenge.Umlauf as [Umlauf Salesianer (Artikel-Größe)],
  UmlaufmengeStandort.Umlauf as [Umlauf Standort (Artikel-Größe)],
  Bestort.Bestand as [Bestand am Lagerort],
  Abc.ABCBez$LAN$ AS [ABC-Klasse], 
  BestOrt.Bestand, 
  BestOrt.Reserviert,
  BestOrt.BestandUrsprung AS [Bestand vom Ursprungsartikel], 
  Bestand.Gleitpreis, 
  LagerteileHist.EKPreis,
  UmlaufSalesianerArtikel.Umlauf AS [Umlauf Salesianer (Artikel)],
  StandortUmlaufSalesianerArtikel.Umlauf AS [Umlauf Standort (Artikel)],
  [Standort mit höchstem Umlauf] = (
    SELECT TOP 1 Standort.Bez
    FROM (
      SELECT StandortID, ArtikelID, SUM(Umlauf) AS Umlauf
      FROM #Umlauf_Salesianer_1401
      GROUP BY StandortID, ArtikelID
    ) AS ArtikelUmlaufStandort
    JOIN Standort ON ArtikelUmlaufStandort.StandortID = Standort.ID
    WHERE ArtikelUmlaufStandort.ArtikelID = LagerteileHist.ArtikelID
    ORDER BY ArtikelUmlaufStandort.Umlauf DESC
  ),
  [Höchste Umlaufmenge] = (
    SELECT TOP 1 ArtikelUmlaufStandort.Umlauf
    FROM (
      SELECT StandortID, ArtikelID, SUM(Umlauf) AS Umlauf
      FROM #Umlauf_Salesianer_1401
      GROUP BY StandortID, ArtikelID
    ) AS ArtikelUmlaufStandort
    JOIN Standort ON ArtikelUmlaufStandort.StandortID = Standort.ID
    WHERE ArtikelUmlaufStandort.ArtikelID = LagerteileHist.ArtikelID
    ORDER BY ArtikelUmlaufStandort.Umlauf DESC
  ),
  Applikationen = STUFF((
    SELECT N', ' + Artikel.ArtikelBez$LAN$ + N' (' + ArtiType.ArtiTypeBez$LAN$ + N')'
    FROM TeilAppl
    JOIN Artikel ON TeilAppl.ApplArtikelID = Artikel.ID
    JOIN ArtiType ON TeilAppl.ArtiTypeID = ArtiType.ID
    WHERE TeilAppl.EinzHistID = LagerteileHist.EinzHistID
      AND TeilAppl.Bearbeitung = N'-'
    FOR XML PATH('')
  ), 1, 2, '')
FROM #LagerteileHist_1401 LagerteileHist
JOIN Bestand ON LagerteileHist.ArtGroeID = Bestand.ArtGroeID AND LagerteileHist.LagerartID = Bestand.LagerartID
JOIN BestOrt ON LagerteileHist.LagerortID = BestOrt.LagerortID AND BestOrt.BestandID = Bestand.ID
JOIN Lagerort ON Bestort.LagerOrtID = Lagerort.ID
JOIN LagSchr ON Lagerort.LagSchrID = LagSchr.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON LagerteileHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON LagerteileHist.ArtikelID = Artikel.ID
JOIN Abc ON Artikel.AbcID = Abc.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez 
  FROM [Status] 
  WHERE [Status].Tabelle = N'ARTIKEL'
) AS Artikelstatus ON LagerteileHist.Status = Artikelstatus.Status
JOIN (
  SELECT ArtikelID, STRING_AGG(SuchCode, ', ') WITHIN GROUP (ORDER BY SuchCode) AS VerwendetIn
  FROM (
    SELECT DISTINCT Artikel.ID AS ArtikelID, Standort.Suchcode
    FROM KdArti
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID 
    JOIN Kunden ON KdArti.KundenID = Kunden.ID 
    JOIN Standort ON Kunden.StandortID = Standort.ID
  ) x
  GROUP BY ArtikelID
) AS ArtikelverwendungStandort ON LagerteileHist.ArtikelID = ArtikelverwendungStandort.ArtikelID
JOIN Kunden ON LagerteileHist.KundenID = Kunden.ID
JOIN Vsa ON LagerteileHist.VsaID = Vsa.ID
LEFT JOIN (
  SELECT ArtGroeID, ArtikelID, SUM(Umlauf) AS Umlauf
  FROM #Umlauf_Salesianer_1401
  GROUP BY ArtGroeID, ArtikelID
) AS Umlaufmenge ON LagerteileHist.ArtGroeID = Umlaufmenge.ArtGroeID and LagerteileHist.ArtikelID = Umlaufmenge.ArtikelID
LEFT JOIN (
  SELECT ArtikelID, SUM(Umlauf) AS Umlauf
  FROM #Umlauf_Salesianer_1401
  GROUP BY ArtikelID
) AS UmlaufSalesianerArtikel ON LagerteileHist.ArtikelID = UmlaufSalesianerArtikel.ArtikelID
LEFT JOIN (
  SELECT ArtGroeID, ArtikelID, Umlauf
  FROM #Umlauf_Salesianer_1401
  WHERE StandortID = @LagerID
) AS UmlaufmengeStandort ON LagerteileHist.ArtgroeID = UmlaufmengeStandort.ArtgroeID and LagerteileHist.ArtikelID = UmlaufmengeStandort.ArtikelID
LEFT JOIN (
  SELECT ArtikelID, SUM(Umlauf) AS Umlauf
  FROM #Umlauf_Salesianer_1401
  WHERE StandortID = @LagerID
  GROUP BY ArtikelID
) AS StandortUmlaufSalesianerArtikel ON LagerteileHist.ArtikelID = StandortUmlaufSalesianerArtikel.ArtikelID
WHERE Standort.ID = @LagerID
  AND ((0 = 1 AND Lagerart.Neuwertig = 1) OR (0 = 0))
ORDER BY Lagerort.LagerOrt;