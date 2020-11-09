DECLARE @RwConfigID int = (SELECT RwConfig.ID FROM RwConfig WHERE RwConfig.RwConfigBez = N'Landeskliniken RW Stufen');
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @NewConfig TABLE (
  NewRwConfigID int
);

INSERT INTO RwConfig (RwConfigBez, RwConfigBez1, RwConfigBez2, RwConfigBez3, RwConfigBez4, RwConfigBez5, RwConfigBez6, RwConfigBez7, RwConfigBez8, RKoTypeID, RWFakIVSA, RueckVar, RueckVarTausch, MinRWEri, MinRWAbsch, RWBerechnungsVar, HideRwRueckErin, AnlageUserID_, UserID_)
OUTPUT inserted.ID
INTO @NewConfig
SELECT LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez1, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez2, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez3, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez4, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez5, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez6, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez7, LEFT(N'UHF Pool - ' + RwConfigBez, 40) AS RwConfigBez8, 91 AS RKoTypeID, RWFakIVSA, RueckVar, RueckVarTausch, MinRWEri, MinRWAbsch, RWBerechnungsVar, HideRwRueckErin, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM RwConfig
WHERE ID = @RwConfigID;

INSERT INTO RwConfPo (RwConfigID, RwArtID, VkAufschlagProz, MinimumRwAbs, MinimumRwProz, MindestRWAbs, MindestRwProz, RPoBezTemplate, RPoMemoTemplate, GroeZuschBasisRW, KonstantRwProz, EKGrundAkt, EKGrundHist, EKZuschlAkt, EKZuschlHist, EKNsEmbAkt, IncludeWarehTime, PauschalRwAbs, UseKdArtiVkPreis, AnlageUserID_, UserID_)
SELECT NewConfig.NewRwConfigID AS RwConfigID, RwConfPo.RwArtID, RwConfPo.VkAufschlagProz, IIF(RwConfPo.RwArtID = 9, 90000, RwConfPo.MinimumRwAbs) AS MinimumRwAbs, IIF(RwConfPo.RwArtID = 9, 1000, RwConfPo.MinimumRwProz) AS MinimumRwProz, RwConfPo.MindestRWAbs, RwConfPo.MindestRwProz, N'[ARTIBEZ]' AS RPoBezTemplate, N'' AS RPoMemoTemplate, RwConfPo.GroeZuschBasisRW, RwConfPo.KonstantRwProz, RwConfPo.EKGrundAkt, RwConfPo.EKGrundHist, RwConfPo.EKZuschlAkt, RwConfPo.EKZuschlHist, RwConfPo.EKNsEmbAkt, RwConfPo.IncludeWarehTime, RwConfPo.PauschalRwAbs, RwConfPo.UseKdArtiVkPreis, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM RwConfPo
CROSS JOIN @NewConfig AS NewConfig
WHERE RwConfPo.RwConfigID = @RwConfigID;