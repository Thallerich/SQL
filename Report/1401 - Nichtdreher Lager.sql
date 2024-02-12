DROP TABLE IF EXISTS #LagerteileHist_934;
DROP TABLE IF EXISTS #Artikelanzahl_Lagerort_934;
DROP TABLE IF EXISTS #Umlauf_Salesianer_934;
DROP TABLE IF EXISTS #Umlauf_Standort_934;

DECLARE @LagerID as INT
SET @LagerID = ($1$)

DECLARE @CurrentWeek nchar(7);
SET @CurrentWeek = (
  SELECT Week.Woche
  FROM Week
  WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat
);

CREATE TABLE #LagerteileHist_934
( 
    Barcode varchar(33) collate Latin1_General_CS_AS, 
    EinzteilID int,
    KundenID int,
    Lagerort nvarchar(20) collate Latin1_General_CS_AS, 
    LagerortID int, 
    LagerartID int, 
    LagerartBez nvarchar(40) collate Latin1_General_CS_AS, 
    ArtikelID int,
    ArtikelNr nvarchar(15) collate Latin1_General_CS_AS, 
    ArtikelBez nvarchar(60) collate Latin1_General_CS_AS, 
    ABCID int, 
    ArtGroeID int, 
    Größe nvarchar(12) collate Latin1_General_CS_AS, 
    EKPreis money, 
    [Status] nvarchar(2) collate Latin1_General_CS_AS,
    EinzHistVon date,
    RuecklaufG int
);


    
CREATE INDEX Ind_LagerortID ON #LagerteileHist_934 (LagerortID);
CREATE INDEX Ind_ArtGroeID ON #LagerteileHist_934 (ArtGroeID);
CREATE INDEX Ind_LagerartID ON #LagerteileHist_934 (LagerartID);
    
INSERT INTO #LagerteileHist_934 (Barcode,EinzteilID,KundenID,Lagerort,LagerortID,LagerartID,LagerartBez,ArtikelID,ArtikelNr,ArtikelBez,ABCID,ArtGroeID,Größe,EKPreis,Status, EinzHistVon, RuecklaufG)
    SELECT 
        EINZHIST.Barcode, 
        EINZHIST.EinzTeilID,
        EINZHIST.KundenID,
        Lagerort.LagerOrt,
        Lagerort.Id as LagerortID, 
        EinzHist.LagerArtID, 
        Lagerart.LagerartBez,
        Artikel.Id as ArtikelID, 
        Artikel.ArtikelNr, 
        Artikel.ArtikelBez$LAN$, 
        Artikel.AbcID, 
        EinzHist.ArtGroeID, 
        Artgroe.Groesse, 
        ArtGroe.EKPreis, 
        Einzhist.Status,
        EinzHist.EinzHistVon,
        EinzTeil.RuecklaufG
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN LAGERORT ON Einzhist.LagerOrtID = LagerOrt.ID 
    JOIN LAGERART ON EINZHIST.LagerArtID = Lagerart.Id 
    JOIN ARTIKEL ON Einzhist.ArtikelID = ARtikel.ID 
    JOIN ARTGROE on Einzhist.ArtGroeID = artgroe.ID 
    where lagerart.LagerID = 1 
    and Einzhist.Status in ('X','XE','XM') 
    and EinzHist.EinzHistTyp = 2;

CREATE TABLE #Umlauf_Salesianer_934
(
--    VsaID Int,
--    TraegerID Int,
--    KdartID Int,
    ArtGroeID Int,
    ArtikelID Int,
    Umlauf Int
)  

CREATE INDEX Ind_ArtikelId ON #Umlauf_Salesianer_934(ArtikelID)
CREATE INDEX Ind_ArtGroe ON #Umlauf_Salesianer_934(ArtgroeID)

INSERT INTO #Umlauf_Salesianer_934(ArtGroeID,ArtikelID,Umlauf)
    SELECT /*VsaID, TraegerID, KdArtiID,*/ ArtGroeID, ArtikelID, SUM(Umlauf) AS Umlauf 
FROM ( 
    SELECT /*VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID,*/ COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf 
    FROM VsaLeas 
    JOIN Vsa ON VsaLeas.VsaID = Vsa.ID 
    JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
    WHERE @CurrentWeek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') 
    AND ISNULL(VsaLeas.Ausdienst, N'2099/52') 
    GROUP BY /*VsaLeas.VsaID, VsaLeas.KdArtiID,*/ COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID 
    
    UNION ALL 
    
    SELECT /*VsaAnf.VsaID, - 1 AS TraegerID, VsaAnf.KdArtiID,*/ COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf 
    FROM VsaAnf 
    JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
    WHERE VsaAnf.Bestand != 0 AND VsaAnf.[Status] = N'A' 
    GROUP BY /*VsaAnf.VsaID, VsaAnf.KdArtiID,*/ COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID 
    
    UNION ALL 
    
    SELECT /*Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID,*/ COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf 
    FROM Strumpf JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
    WHERE Strumpf.[Status] != N'X' 
    AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek 
    AND Strumpf.WegGrundID < 0 
    GROUP BY /* Strumpf.VsaID, Strumpf.KdArtiID,*/ COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID 
    
    UNION ALL 
    
    SELECT /*Traeger.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID,*/ TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
    FROM TraeArti 
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID 
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    
    UNION ALL 
    
    SELECT  /*Traeger.VsaID,TraeArti.TraegerID, KdArti.ID AS KdArtiID,*/ COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
    FROM TraeArti 
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID 
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID 
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND KdArAppl.ArtiTypeID = 3 --Emblem 
    
    UNION ALL 
    
    SELECT  /*Traeger.VsaID,TraeArti.TraegerID,KdArti.ID AS KdArtiID,*/  COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
    FROM TraeArti 
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID 
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID 
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
    ) AS x 
    GROUP BY /*VsaID, TraegerID, KdArtiID,*/ ArtGroeID, ArtikelID;

CREATE TABLE #Umlauf_Standort_934 (
    ArtgroeID int,
    ArtikelID int,
    UmlaufStandortbezogen int
)

CREATE INDEX Ind_ArtikelId ON #Umlauf_Standort_934(ArtikelID)
CREATE INDEX Ind_ArtGroe ON #Umlauf_Standort_934(ArtgroeID)

INSERT INTO #Umlauf_Standort_934(ArtgroeID,ArtikelID,UmlaufStandortbezogen)

  SELECT /*VsaID, TraegerID, KdArtiID,*/ ArtGroeID, ArtikelID, SUM(Umlauf) AS Umlauf 
FROM ( 
    SELECT /*VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID,*/ COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf 
    FROM VsaLeas 
    JOIN Vsa ON VsaLeas.VsaID = Vsa.ID 
    JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID 
    JOIN KDBER ON KDARTI.KdBerID = Kdber.Id
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
    join standkon on vsa.StandKonID = standkon.ID
    join standber on standber.StandKonID = standkon.ID and kdber.bereichid = standber.bereichId 
    WHERE @CurrentWeek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') 
    AND ISNULL(VsaLeas.Ausdienst, N'2099/52') 
    AND (LokalLagerID = @LagerID OR LagerID = @LagerID)
    GROUP BY /*VsaLeas.VsaID, VsaLeas.KdArtiID,*/ COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID 
    
    UNION ALL 
    
    SELECT /*VsaAnf.VsaID, - 1 AS TraegerID, VsaAnf.KdArtiID,*/ COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf 
    FROM VsaAnf 
    JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID 
    JOIN KDBER on KDARTI.KDBERID = kdber.Id 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
    JOIN VSA ON VsaAnf.VsaID = vsa.id 
    join standkon on vsa.StandKonID = standkon.ID
    join standber on standber.StandKonID = standkon.ID and standber.bereichId = kdber.bereichID 
    WHERE VsaAnf.Bestand != 0 AND VsaAnf.[Status] = N'A' 
    and (LokalLagerID = @LagerID OR LagerID = @LagerID)
    GROUP BY /*VsaAnf.VsaID, VsaAnf.KdArtiID,*/ COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID 
    
    UNION ALL 
    
    SELECT /* Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID,*/ COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf 
    FROM Strumpf 
    JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID 
    JOIN kdber on KDARTI.kdberid = kdber.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-' 
    join vsa on strumpf.VsaID = vsa.id 
    join standkon on vsa.StandKonID = standkon.ID
    join standber on standber.StandKonID = standkon.ID and kdber.bereichID = standber.bereichid 
    WHERE Strumpf.[Status] != N'X' 
    AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek 
    AND Strumpf.WegGrundID < 0 
    and (LokalLagerID = @LagerID OR LagerID = @LagerID)
    GROUP BY /*Strumpf.VsaID, Strumpf.KdArtiID,*/ COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID 
    
    UNION ALL 
    
    SELECT  /*Traeger.VsaID,TraeArti.TraegerID, TraeArti.KdArtiID,*/ TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
    FROM TraeArti 
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID 
    JOIN kdber on KDARTI.kdberid = kdber.ID 
    JOIN VSA on Traeger.VsaID = Vsa.ID 
    join standkon on vsa.StandKonID = standkon.ID
    join standber on standber.StandKonID = standkon.ID and kdber.bereichID = standber.bereichid 
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    and  (LokalLagerID = @LagerID OR LagerID = @LagerID)
    
    UNION ALL 
    
    SELECT  /*Traeger.VsaID,TraeArti.TraegerID, KdArti.ID AS KdArtiID,*/ COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
    FROM TraeArti 
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID 
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID 
    JOIN kdber ON KDARTI.kdberid = kdber.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID 
    join vsa on traeger.vsaid = vsa.id 
    join standkon on vsa.StandKonID = standkon.ID
    join standber on standber.StandKonID = standkon.ID and kdber.bereichID = standber.bereichID 
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND KdArAppl.ArtiTypeID = 3 --Emblem 
    and (LokalLagerID = @LagerID OR LagerID = @LagerID)
    
    UNION ALL 
    
    SELECT  /*Traeger.VsaID,TraeArti.TraegerID,KdArti.ID AS KdArtiID,*/  COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf 
    FROM TraeArti 
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID 
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID 
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID 
    JOIN kdber ON KDARTI.KdBerID = kdber.ID 
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID 
    JOIN VSA on Traeger.Vsaid = vsa.id 
    join standkon on vsa.StandKonID = standkon.ID
    join standber on standber.StandKonID = standkon.ID and kdber.bereichid = standber.bereichID 
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52') 
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
    and  (LokalLagerID = @LagerID OR LagerID = @LagerID)
    ) AS x 
    GROUP BY /*VsaID, TraegerID, KdArtiID,*/ ArtGroeID, ArtikelID;
    
WITH Artikelstatus AS ( 
    SELECT 
        [Status].ID, 
        [Status].[Status], 
        [Status].StatusBez$LAN$ AS StatusBez 
    FROM [Status] 
    WHERE [Status].Tabelle = N'ARTIKEL'
),
    
Teilestatus as ( 
    SELECT 
        [Status].ID, 
        [Status].[Status], 
        [Status].StatusBez$LAN$ AS StatusBez 
    FROM 
        [Status] 
    WHERE 
        [Status].Tabelle = N'EINZHIST'
),
ArtikelverwendungStandort as (
  SELECT ArtikelID, STRING_AGG(SuchCode, ',') WITHIN GROUP (order by SuchCode) as VerwendetIn
  FROM (
    SELECT distinct Artikel.ID as ArtikelID, Standort.Suchcode as SuchCode
    from kdarti
    JOIN ARTIKEL ON KDARTI.ArtikelID = Artikel.ID 
    JOIN KUNDEN ON KDARTI.KundenID = Kunden.ID 
    JOIN STANDORT ON Kunden.StandortID = Standort.ID
  ) x
  group by artikelID
)
SELECT 
    LagerteileHist.Barcode,
    Kunden.KDNR,
    Kunden.SuchCode as [Letzter Kunde],
    LagerteileHist.RuecklaufG as [Anzahl Wäschen],
    LagerteileHist.EinzHistVon AS [im Lager seit],
    Standort.Bez AS Lagerstandort, 
    Lagerort.Lagerort, 
    LagSchr.Bez AS Lagerschrank, 
    Lagerart.LagerartBez$LAN$ AS Lagerart, 
    Lagerart.Zustand, 
    LagerArt.Neuwertig, 
    LagerteileHist.ArtikelNr, 
    LagerteileHist.ArtikelBez AS Artikelbezeichnung, 
    LagerteileHist.Größe,
    ArtikelverwendungStandort.VerwendetIn,
    Artikelstatus.StatusBez AS Artikelstatus, 
    Umlaufmenge.Umlauf as [Umlauf Salesianer (Artikel-Größe)],
    UmlaufmengeStandort.UmlaufStandortbezogen as [Umlauf Standort (Artikel-Größe)],
    Bestort.Bestand as [Bestand am Lagerort],
    ABC.ABCBez, 
    LagerteileHist.Größe, 
    BestOrt.Bestand, 
    BestOrt.Reserviert,
    BestOrt.BestandUrsprung AS [Bestand vom Ursprungsartikel], 
    Bestand.Gleitpreis, 
    LagerteileHist.EKPreis,
    UmlaufSalesianerArtikel.Umlauf AS [Umlauf Salesianer (Artikel)],
    StandortUmlaufSalesianerArtikel.Umlauf AS [Umlauf Standort (Artikel)]
FROM #LagerteileHist_934 LagerteileHist
JOIN Bestand ON LagerteileHist.ArtGroeID = Bestand.ArtGroeID AND LagerteileHist.LagerartID = Bestand.LagerartID
JOIN BestOrt ON LagerteileHist.LagerortID = BestOrt.LagerortID AND BestOrt.BestandID = Bestand.ID
JOIN Lagerort ON Bestort.LagerOrtID = Lagerort.ID
JOIN LagSchr ON Lagerort.LagSchrID = LagSchr.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ABC ON LagerteileHist.AbcID = ABC.ID
JOIN Artikelstatus ON LagerteileHist.Status = Artikelstatus.Status
JOIN ArtikelverwendungStandort ON LagerteileHist.ArtikelID = ArtikelverwendungStandort.ArtikelID
JOIN KUNDEN ON LagerteileHist.KundenID = Kunden.ID
LEFT JOIN #Umlauf_Salesianer_934 Umlaufmenge ON LagerteileHist.ArtGroeID = Umlaufmenge.ArtGroeID and LagerteileHist.ArtikelID = Umlaufmenge.ArtikelID
LEFT JOIN (
  SELECT #Umlauf_Salesianer_934.ArtikelID, SUM(#Umlauf_Salesianer_934.Umlauf) AS Umlauf
  FROM #Umlauf_Salesianer_934
  GROUP BY #Umlauf_Salesianer_934.ArtikelID
) AS UmlaufSalesianerArtikel ON LagerteileHist.ArtikelID = UmlaufSalesianerArtikel.ArtikelID
LEFT JOIN #Umlauf_Standort_934 UmlaufmengeStandort ON LagerteileHist.ArtgroeID = UmlaufmengeStandort.ArtgroeID and LagerteileHist.ArtikelId = UmlaufmengeStandort.ArtikelId
LEFT JOIN (
  SELECT #Umlauf_Standort_934.ArtikelID, SUM(#Umlauf_Standort_934.UmlaufStandortbezogen) AS Umlauf
  FROM #Umlauf_Standort_934
  GROUP BY #Umlauf_Standort_934.ArtikelID
) AS StandortUmlaufSalesianerArtikel ON LagerteileHist.ArtikelID = StandortUmlaufSalesianerArtikel.ArtikelID
WHERE Standort.ID = @LagerID
  AND ((0 = 1 AND Lagerart.Neuwertig = 1) OR (0 = 0))
ORDER BY Lagerort.LagerOrt;