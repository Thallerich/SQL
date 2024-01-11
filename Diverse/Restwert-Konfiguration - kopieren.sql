DECLARE @rwconfigid int = 1099;
DECLARE @constrwpercent int = 35;

DECLARE @sourcepercent nchar(3) = (SELECT CAST(RwConfPo.KonstantRwProz AS nchar(3)) FROM RwConfPo WHERE RwConfPo.RwConfigID = @rwconfigid AND RwConfPo.RwArtID = 1);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @newconfigid int;

DECLARE @RwConfig TABLE (
  RwConfigID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO RwConfig (RwConfigBez, RwConfigBez1, RwConfigBez2, RwConfigBez3, RwConfigBez4, RwConfigBez5, RwConfigBez6, RwConfigBez7, RwConfigBez8, RwConfigBez9, RwConfigBezA, RKoTypeID, RWFakIVSA, RueckVar, RueckVarTausch, MinRWEri, MinRWAbsch, RWBerechnungsVar, HideRwRueckErin, [Status], RestwertArt, AnlageUserID_, UserID_)
    OUTPUT inserted.ID INTO @RwConfig (RwConfigID)
    SELECT REPLACE(RwConfig.RwConfigBez, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez,
      REPLACE(RwConfig.RwConfigBez1, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez1,
      REPLACE(RwConfig.RwConfigBez2, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez2,
      REPLACE(RwConfig.RwConfigBez3, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez3,
      REPLACE(RwConfig.RwConfigBez4, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez4,
      REPLACE(RwConfig.RwConfigBez5, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez5,
      REPLACE(RwConfig.RwConfigBez6, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez6,
      REPLACE(RwConfig.RwConfigBez7, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez7,
      REPLACE(RwConfig.RwConfigBez8, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez8,
      REPLACE(RwConfig.RwConfigBez9, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBez9,
      REPLACE(RwConfig.RwConfigBezA, @sourcepercent, CAST(@constrwpercent AS nchar(3))) AS RwConfigBezA,
      RwConfig.RKoTypeID,
      RwConfig.RWFakIVSA,
      RwConfig.RueckVar,
      RwConfig.RueckVarTausch,
      RwConfig.MinRWEri,
      RwConfig.MinRWAbsch,
      RwConfig.RWBerechnungsVar,
      RwConfig.HideRwRueckErin,
      RwConfig.[Status],
      RwConfig.RestwertArt,
      @userid AS AnlageUserID_,
      @userid AS UserID
    FROM RwConfig
    WHERE ID = @rwconfigid;

    SELECT @newconfigid = RwConfigID FROM @RwConfig;

    INSERT INTO RwConfPo (RwConfigID, RwArtID, VkAufschlagProz, VkAufschlagAbs, MinimumRwAbs, MinimumRwProz, MindestRWAbs, MindestRwProz, MindestRwProzNachAfa, RwTemplaID, GroeZuschBasisRW, KonstantRwProz, EKGrundAkt, EKGrundHist, EKZuschlAkt, EKZuschlHist, EKNsEmbAkt, EKNsEmbHist, IncludeWarehTime, PauschalRwAbs, UseKdArtiVkPreis, RwRechPoProTeil, AnlageUserID_, UserID_)
    SELECT @newconfigid AS RwConfigID,
      RwConfPo.RwArtID,
      RwConfPo.VkAufschlagProz,
      RwConfPo.VkAufschlagAbs,
      RwConfPo.MinimumRwAbs,
      RwConfPo.MinimumRwProz,
      RwConfPo.MindestRWAbs,
      @constrwpercent AS MindestRwProz,
      @constrwpercent AS MindestRwProzNachAfa,
      RwConfPo.RwTemplaID,
      RwConfPo.GroeZuschBasisRW,
      @constrwpercent AS KonstantRwProz,
      RwConfPo.EKGrundAkt,
      RwConfPo.EKGrundHist,
      RwConfPo.EKZuschlAkt,
      RwConfPo.EKZuschlHist,
      RwConfPo.EKNsEmbAkt,
      RwConfPo.EKNsEmbHist,
      RwConfPo.IncludeWarehTime,
      RwConfPo.PauschalRwAbs,
      RwConfPo.UseKdArtiVkPreis,
      RwConfPo.RwRechPoProTeil,
      @userid AS AnlageUserID_,
      @userid AS UserID
    FROM RwConfPo
    WHERE RwConfPo.RwConfigID = @rwconfigid

    INSERT INTO RwConSic (RwConfigID, SichtbarID, AnlageUserID_, UserID_)
    SELECT @newconfigid AS RwConfigID,
      RwConSic.SichtbarID,
      @userid AS AnlageUserID_,
      @userid AS UserID_
    FROM RwConSic
    WHERE RwConSic.RwConfigID = @rwconfigid;
  
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