DROP TABLE IF EXISTS #RestwertTeile;

CREATE TABLE #RestwertTeile (
  Code nvarchar(33) COLLATE Latin1_General_CS_AS
);

BULK INSERT #RestwertTeile FROM N'D:\AdvanTex\Temp\op_restwert.txt'
WITH (FIELDTERMINATOR = N'\r', ROWTERMINATOR = N'\n');

DECLARE @KdNr             Integer = 2265;
DECLARE @AAddCondition    NVARCHAR(max) =  N'OPTeile.ID IN (SELECT OPTeile.ID FROM OPTeile JOIN #RestwertTeile AS RWTeile ON RWTeile.Code = OPTeile.Code)';
DECLARE @ARwConfigID      Integer = (SELECT Kunden.RWPoolTeileConfigID FROM Kunden WHERE KdNr = @KdNr);
DECLARE @ARwArtID         Integer = 1; --Fehlteile
DECLARE @ASetAusDRestwert BIT = 0; -- Ausdienst-Restwert nicht setzen

--============================================================================--
--                         CalculateRestWerte                                 --
--============================================================================--

-- Basiswerte festlegen
--------------------------------------------------------------------------------
DECLARE @RWBerechnungsVar INTEGER;
DECLARE @RWConfPo CURSOR;

-- CURSOR Variables RwConfPo
DECLARE @RwConfPoKonstantRwProz integer;
DECLARE @RwConfPoStufe1Wert integer;
DECLARE @RwConfPoStufe2Wert integer;
DECLARE @RwConfPoStufe1Proz integer;
DECLARE @RwConfPoStufe3Wert integer;
DECLARE @RwConfPoStufe2Proz integer;
DECLARE @RwConfPoStufe3Proz integer;
DECLARE @RwConfPoMindestRwProz integer;
DECLARE @RwConfPoMindestRwAbs money;
DECLARE @RwConfPoEKGrundAkt BIT;
DECLARE @RwConfPoEKGrundHist BIT;
DECLARE @RwConfPoEKZuschlAkt BIT;
DECLARE @RwConfPoEKZuschlHist BIT;
DECLARE @RwConfPoVkAufschlagProz integer;
DECLARE @RwConfPoGroeZuschBasisRW BIT;

DECLARE @WegFeld NVARCHAR(max);
DECLARE @VonFeld NVARCHAR(max);
DECLARE @FaktorSelect NVARCHAR(max);
DECLARE @SQL NVARCHAR(max);
DECLARE @SELECTGroeZuschBasisRW NVARCHAR(max);
DECLARE @SELECTGroeZuschBasisRWKdArti NVARCHAR(max);
DECLARE @FROMGroeZuschBasisRW NVARCHAR(max);
DECLARE @WHEREGroeZuschBasisRW NVARCHAR(max);
DECLARE @AddAddCondition NVARCHAR(max);
 
SET @RWBerechnungsVar = (SELECT RWBerechnungsVar FROM RwConfig WHERE ID = @ARwConfigID);

SET @RwConfPo = CURSOR FORWARD_ONLY READ_ONLY FOR 
SELECT KonstantRwProz,
 Stufe1Wert,
 Stufe2Wert,
 Stufe1Proz,
 Stufe3Wert,
 Stufe2Proz,
 Stufe3Proz,
 MindestRwProz,
 MindestRwAbs,
 EKGrundAkt,
 EKGrundHist,
 EKZuschlAkt,
 EKZuschlHist,
 VkAufschlagProz,
 GroeZuschBasisRW FROM RwConfPo WHERE RwConfigID = @ARwConfigID AND RwArtID = @ARwArtID;

OPEN @RwConfPo;
FETCH NEXT FROM @RwConfPo INTO 
 @RwConfPoKonstantRwProz,
 @RwConfPoStufe1Wert,
 @RwConfPoStufe2Wert,
 @RwConfPoStufe1Proz,
 @RwConfPoStufe3Wert,
 @RwConfPoStufe2Proz,
 @RwConfPoStufe3Proz,
 @RwConfPoMindestRwProz,
 @RwConfPoMindestRwAbs,
 @RwConfPoEKGrundAkt,
 @RwConfPoEKGrundHist,
 @RwConfPoEKZuschlAkt,
 @RwConfPoEKZuschlHist,
 @RwConfPoVkAufschlagProz,
 @RwConfPoGroeZuschBasisRW;

WHILE @@FETCH_STATUS = 0 BEGIN

--------------------------------------------------------------------------------

-- AlterInfo aktualisieren
--------------------------------------------------------------------------------
EXECUTE dbo.procOpTeileUpdateAlterInfo @AAddCondition=@AAddCondition;
--------------------------------------------------------------------------------

-- Berechnungen durchführen
--------------------------------------------------------------------------------
-- Felder die für den Faktor genommen werden sollen; je nach Abrechnungsvariante
-- entweder RuecklaufG zu MaxWaschen oder AlterInfo zu AFAWochen
-- Abrechnungsvariante 1 & 3 gehen über AlterInfo  zu AFAWochen
-- Abrechnungsvariante 2 & 4 gehen über RuecklaufG zu MaxWaschen
-- Abrechnungsvariante 5 ist konstant
IF (@RWBerechnungsVar = 1) BEGIN
  SET @WegFeld = 'OpTeile.AlterInfo';
  SET @VonFeld = 'Artikel.AfaWochen';
END;
IF (@RWBerechnungsVar = 3) BEGIN
  SET @WegFeld = 'OpTeile.AlterInfo';
  SET @VonFeld = 'Artikel.AfaWochen';
END;
IF (@RWBerechnungsVar = 6) BEGIN
  SET @WegFeld = 'OpTeile.AlterInfo';
  SET @VonFeld = 'Artikel.AfaWochen';
END;
IF (@RWBerechnungsVar = 2) BEGIN
  SET @WegFeld = 'OpTeile.AnzWasch';
  SET @VonFeld = 'Artikel.MaxWaschen';
END;
IF (@RWBerechnungsVar = 4) BEGIN
  SET @WegFeld = 'OpTeile.AnzWasch';
  SET @VonFeld = 'Artikel.MaxWaschen';
END;


IF @RWBerechnungsVar = 5 BEGIN
  SET @FaktorSelect = CAST(@RwConfPoKonstantRwProz AS VARCHAR) + ' / 100.00 Faktor, -9999 FaktorNegativ';
END ELSE IF @RWBerechnungsVar = 6 BEGIN
  SET @FaktorSelect = 'IIF(' + @WegFeld + ' < ' + CAST(@RwConfPoStufe1Wert AS VARCHAR) + ', ' +
          '1, ' +
      'IIF((' + @WegFeld + ' >= ' + CAST(@RwConfPoStufe1Wert AS VARCHAR) + ') AND ' +
      '    ((' + @WegFeld + ' < ' + CAST(@RwConfPoStufe2Wert AS VARCHAR) + ') OR (' + CAST(@RwConfPoStufe2Wert AS VARCHAR) + '=0)), ' +
      '    ' + CAST(@RwConfPoStufe1Proz/100.00 AS VARCHAR) + ', ' +
      '    IIF((' + @WegFeld + ' >= ' + CAST(@RwConfPoStufe2Wert AS VARCHAR) + ') AND ' +
      '        ((' + @WegFeld + ' < ' + CAST(@RwConfPoStufe3Wert AS VARCHAR) + ') OR (' + CAST(@RwConfPoStufe3Wert AS VARCHAR) + '=0)), ' +
  '        ' + CAST(@RwConfPoStufe2Proz AS VARCHAR) + '/100.00, ' +
                      '        ' + CAST(@RwConfPoStufe3Proz AS VARCHAR) + '/100.00))) Faktor, -9999 FaktorNegativ';
END ELSE BEGIN
SET @FaktorSelect = 'IIF(1-CAST(' + @WegFeld + ' AS FLOAT)/ ' +
                    '    CAST(' + @VonFeld + ' AS FLOAT) < (' + CAST(@RwConfPoMindestRwProz AS VARCHAR) + ' /100.00), ' +
                    '    ' + CAST(@RwConfPoMindestRwProz AS VARCHAR) + ' /100.00, ' +
                    '    1-CAST(' + @WegFeld + ' AS FLOAT)/CAST(' + @VonFeld + ' AS FLOAT)) Faktor, ' +
                    '    1-CAST(' + @WegFeld + ' AS FLOAT)/CAST(' + @VonFeld + ' AS FLOAT) FaktorNegativ';
END;

DROP TABLE IF EXISTS #tmpCalRestwert; 

IF @RwConfPoGroeZuschBasisRW = 1 BEGIN
  SET @SELECTGroeZuschBasisRW = 'Artikel.BasisRestwert * ((100 + ArtGroe.Zuschlag)/100.00)';
  SET @SELECTGroeZuschBasisRWKdArti = 'Artikel.BasisRestwert * ((100 + ArtGroe.Zuschlag)/100.00)';
  SET @FROMGroeZuschBasisRW = ', Artgroe';
  SET @WHEREGroeZuschBasisRW = 'AND OpTeile.ArtGroeID = Artgroe.ID';
END ELSE BEGIN
  SET @SELECTGroeZuschBasisRW = 'Artikel.BasisRestwert';
  SET @SELECTGroeZuschBasisRWKdArti = 'Artikel.BasisRestwert';
  SET @FROMGroeZuschBasisRW = '';
  SET @WHEREGroeZuschBasisRW = '';
END;

IF @AAddCondition <> '' BEGIN
  SET @AddAddCondition = 'AND ' + @AAddCondition;
END ELSE BEGIN 
  SET @AddAddCondition = '';
END;

CREATE TABLE #tmpCalRestwert
(
  OpTeileID integer,
  Status NVARCHAR(2),
  Ausdienst NVARCHAR(7),
  AnzWasch integer,
  MaxWaschen integer,
  AlterInfo integer,
  AfaWochen integer,
  AusDRestwert money,
  MindestRwProz integer,
  MindestRwAbs money,
  BasisAfA FLOAT,
  Faktor FLOAT,
  FaktorNegativ FLOAT,
  FaktorNeu100Proz FLOAT, 
  RestwertInfo money,
  RestwertInfoNegativ money,
  RestwertInfoNeu100Proz money
)
SET @SQL =
'SELECT OpTeile.ID OpTeileID, OpTeile.Status, dbo.WeekOfDate(OpTeile.WegDatum) Ausdienst,
OpTeile.AnzWasch, Artikel.MaxWaschen,
OpTeile.AlterInfo,  Artikel.AfaWochen, OpTeile.AusDRestwert, ' +
CAST(@RwConfPoMindestRwProz AS VARCHAR) + ' MindestRwProz, ' +
CAST(@RwConfPoMindestRwAbs AS VARCHAR) + ' MindestRwAbs,

      IIF(Artikel.BasisRestwert = 0,
          (
           IIF(' + CAST(@RwConfPoEKGrundAkt AS VARCHAR) + ' = 1,   OpTeile.EKGrundAkt,   CAST(0.0 AS FLOAT)) +
           IIF(' + CAST(@RwConfPoEKGrundHist AS VARCHAR) + ' = 1,  OpTeile.EKGrundHist,  CAST(0.0 AS FLOAT)) +
           IIF(' + CAST(@RwConfPoEKZuschlAkt AS VARCHAR) + ' = 1,  OpTeile.EKZuschlAkt,  CAST(0.0 AS FLOAT)) +
           IIF(' + CAST(@RwConfPoEKZuschlHist AS VARCHAR) + ' = 1, OpTeile.EKZuschlHist, CAST(0.0 AS FLOAT))
          ) * (1 + ' + CAST(@RwConfPoVkAufschlagProz AS VARCHAR) + '/100.00)
          ,
          ' +
      @SELECTGroeZuschBasisRW + '
          ) BasisAfA
          ,
      ' + @FaktorSelect + '
      ,
      1.0 FaktorNeu100Proz,
      CAST(0 AS MONEY) RestwertInfo,
      CAST(0 AS MONEY) RestwertInfoNegativ,
      CAST(0 AS MONEY) RestwertInfoNeu100Proz
      FROM
      OpTeile,
      Vsa, Artikel ' + @FROMGroeZuschBasisRW + '
      WHERE Artikel.ID = OpTeile.ArtikelID 
  AND OpTeile.VsaId = Vsa.ID ' +
      @AddAddCondition + ' ' +
      @WHEREGroeZuschBasisRW + ';';
INSERT INTO #tmpCalRestwert EXEC(@SQL);

UPDATE #tmpCalRestwert SET FaktorNegativ = Faktor WHERE FaktorNegativ = -9999;

if @RWBerechnungsVar = 3 BEGIN
 UPDATE #tmpCalRestwert
 SET Faktor =
   IIF(1-CAST(AnzWasch AS FLOAT) / CAST(MaxWaschen AS FLOAT) < @RWConfPoMindestRwProz / 100.00,
       @RWConfPoMindestRwProz / 100.00,
       1-CAST(AnzWasch AS FLOAT) / CAST(MaxWaschen AS FLOAT))
 WHERE AnzWasch >= MaxWaschen;
end;
if @RWBerechnungsVar = 4 BEGIN
 UPDATE #tmpCalRestwert
 SET Faktor =
   IIF(1-CAST(AlterInfo AS FLOAT) / CAST(AfaWochen AS FLOAT) < @RWConfPoMindestRwProz / 100.00,
       @RWConfPoMindestRwProz / 100.00,
       1-CAST(AlterInfo AS FLOAT) / CAST(AfaWochen AS FLOAT))
 WHERE AlterInfo >= AfaWochen;
end;
if @RWBerechnungsVar = 5 BEGIN
 UPDATE #tmpCalRestwert
 SET Faktor = @RWConfPoMindestRwProz / 100.00
 WHERE AlterInfo >= AfaWochen;
end;

--------------------------------------------------------------------------------
-- RestwertInfo füllen
--------------------------------------------------------------------------------

UPDATE #tmpCalRestwert
SET RestWertInfo =
IIF((Ausdienst <> '') AND (dbo.WeekOfDate(dbo.AdvCurrentDate()) >= Ausdienst),
    AusdRestwert,
    IIF((BasisAfA = 0.00) OR (ROUND(BasisAfA * Faktor,2) > @RwConfPoMindestRwAbs),
        ROUND(BasisAfA * Faktor,2),
        @RwConfPoMindestRwAbs
        )
    );


--------------------------------------------------------------------------------
-- RestwertInfo eintragen
--------------------------------------------------------------------------------
UPDATE OpTeile
SET RestWertInfo = x.RestwertInfo
FROM #tmpCalRestwert x
WHERE x.OpTeileID = OpTeile.ID
AND x.RestwertInfo <> OpTeile.RestwertInfo
AND OpTeile.ID IN (SELECT OpTeileID FROM #tmpCalRestwert);

--------------------------------------------------------------------------------
-- Restwert eintragen (falls über ASetAusDRestwert verlangt)
--------------------------------------------------------------------------------
IF @ASetAusDRestwert=1 BEGIN 
 UPDATE OpTeile
 SET AusDRestwert = x.RestwertInfo
 FROM #tmpCalRestwert x
 WHERE x.OpTeileID = OpTeile.ID
 AND x.RestwertInfo <> OpTeile.AusDRestwert
 AND OpTeile.AusDRestwert = 0.00
 AND OpTeile.ID IN (SELECT OpTeileID FROM #tmpCalRestwert);
END;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FETCH NEXT FROM @RwConfPo INTO 
 @RwConfPoKonstantRwProz,
 @RwConfPoStufe1Wert,
 @RwConfPoStufe2Wert,
 @RwConfPoStufe1Proz,
 @RwConfPoStufe3Wert,
 @RwConfPoStufe2Proz,
 @RwConfPoStufe3Proz,
 @RwConfPoMindestRwProz,
 @RwConfPoMindestRwAbs,
 @RwConfPoEKGrundAkt,
 @RwConfPoEKGrundHist,
 @RwConfPoEKZuschlAkt,
 @RwConfPoEKZuschlHist,
 @RwConfPoVkAufschlagProz,
 @RwConfPoGroeZuschBasisRW;
END; -- ENDWHILE @RwConfPo

CLOSE @RwConfPo;
DEALLOCATE @RwConfPo;

DROP TABLE IF EXISTS #tmpCalRestwert; 

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.EKPreis AS [EK aktuell], OPTeile.RestwertInfo AS [Einzelpreis (Restwert)], COUNT(OPTeile.ID) AS Menge
FROM #RestwertTeile AS RWTeile
JOIN OPTeile ON RWTeile.Code = OPTeile.Code
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EKPreis, OPTeile.RestWertInfo
ORDER BY Artikel.ArtikelNr ASC, [EK aktuell] DESC;

DROP TABLE #RestwertTeile;