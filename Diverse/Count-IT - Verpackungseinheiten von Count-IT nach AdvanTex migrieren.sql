/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare Target table on AdvanTex DB                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* DROP TABLE dbo._PackageUnitCIT */

IF OBJECT_ID(N'dbo._PackageUnitCIT') IS NULL
BEGIN
  CREATE TABLE dbo._PackageUnitCIT (
    PackageUnitID bigint,
    CreationDate datetime,
    LocationID int,
    Menge int,
    Sgtin96HexCode nvarchar(33) COLLATE Latin1_General_CS_AS,
    ArticleID int,
    VPSKoID int DEFAULT -1,
    VPSNr nvarchar(16) COLLATE Latin1_General_CS_AS,
    VPSPoID int DEFAULT -1,
    IsLatestVPS bit DEFAULT 0,
    EinzHistID int DEFAULT -1,
    EinzTeilID int DEFAULT -1
  );
END
ELSE
  TRUNCATE TABLE _PackageUnitCIT;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ run on Count-IT DB!                                                                                                       ++ */
/* ++   export to file and import into _PackageUnit on Salesianer DB                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT PackageUnit.PackageUnitID, PackageUnit.CreationDate, PackageUnit.LocationID, PackageUnit.EanPackagingUnit AS Menge, Chip.Sgtin96HexCode, Chip.ArticleID
FROM CustomerSystem.dbo.PackageUnit
JOIN CustomerSystem.dbo.Chip ON Chip.PackageUnitID = PackageUnit.PackageUnitID
WHERE PackageUnit.CreationDate > N'2024-01-01 00:00:00.000';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ prepare work table                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

BEGIN TRY
  BEGIN TRANSACTION;
  
    SELECT DISTINCT _PackageUnitCIT.PackageUnitID, CAST(0 AS int) AS VPSKoID, CAST(N'' AS nvarchar(16)) AS VPSNr
    INTO #VPSKo
    FROM _PackageUnitCIT
    WHERE _PackageUnitCIT.VPSKoID < 0;

    UPDATE #VPSKo SET VPSKoID = NEXT VALUE FOR NextID_VPSKO, VPSNr = RIGHT(REPLICATE(N'0', 8) + CAST(NEXT VALUE FOR NextID_VPSNr AS nvarchar), 8)
    WHERE #VPSKo.VPSKoID = 0;

    SELECT DISTINCT _PackageUnitCIT.PackageUnitID, _PackageUnitCIT.ArticleID, _PackageUnitCIT.Menge, _PackageUnitCIT.CreationDate, CAST(0 AS int) AS VPSPoID
    INTO #VPSPo
    FROM _PackageUnitCIT
    WHERE _PackageUnitCIT.VPSPoID < 0;

    UPDATE #VPSPo SET VPSPoID = NEXT VALUE FOR NextID_VPSPO WHERE #VPSPo.VPSPoID = 0;

    UPDATE _PackageUnitCIT SET VPSKoID = #VPSKo.VPSKoID, VPSNr = #VPSKo.VPSNr
    FROM #VPSKo
    WHERE #VPSKo.PackageUnitID = _PackageUnitCIT.PackageUnitID;

    UPDATE _PackageUnitCIT SET VPSPoID = #VPSPo.VPSPoID
    FROM #VPSPo
    WHERE #VPSPo.PackageUnitID = _PackageUnitCIT.PackageUnitID AND #VPSPo.ArticleID = #VPSPo.ArticleID AND _PackageUnitCIT.Menge = #VPSPo.Menge AND _PackageUnitCIT.CreationDate = #VPSPo.CreationDate;

    UPDATE _PackageUnitCIT SET IsLatestVPS = 1, EinzHistID = x.EinzHistID, EinzTeilID = x.EinzTeilID
    FROM (
      SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, _PackageUnitCIT.Sgtin96HexCode
      FROM _PackageUnitCIT
      JOIN EinzHist ON _PackageUnitCIT.Sgtin96HexCode = EinzHist.Barcode
      JOIN VPSPo ON EinzHist.LastVpsPoID = VPSPo.ID
      JOIN VPSKo ON VPSPo.VPSKoID = VPSKo.ID
      WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
        AND EinzHist.PoolFkt = 1
        AND EinzHist.EinzHistTyp = 1
        AND (_PackageUnitCIT.CreationDate > VPSKo.Anlage_ OR EinzHist.LastVpsPoID = -1)
    ) AS x
    WHERE x.Sgtin96HexCode = _PackageUnitCIT.Sgtin96HexCode;
  
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

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VPSKO / VPSPO - Datensätze erstellen                                                                                      ++ */
/* ++ EinzHist.LastVPSPoID setzen                                                                                               ++ */
/* ++ Scan schreiben (Beispiel Scan.ID = 2834792063)                                                                            ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2024-09-02                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @arbplatzid int = (SELECT ID FROM ArbPlatz WHERE ComputerName = HOST_NAME());

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO VPSKo (ID, VPSTypeID, ZielNrID, VPSNr, [Status], FachNr, Anlage_, AnlageUserID_, UserID_)
    SELECT PU.VPSKoID AS ID, 9 AS VPSTypeID, 250 AS ZielNrID, PU.VPSNr, N'D' AS [Status], -1 AS FachNr, PU.CreationDate AS Anlage_, @userid AS AnlageUserID, @userid AS UserID_
    FROM (
      SELECT DISTINCT _PackageUnitCIT.VPSKoID, _PackageUnitCIT.VPSNr, _PackageUnitCIT.CreationDate
      FROM _PackageUnitCIT
    ) AS PU;

    INSERT INTO VPSPo (ID, VPSKoID, ArtikelID, Menge, Anlage_, AnlageUserID_, UserID_)
    SELECT PU.VPSPoID AS ID, PU.VPSKoID, PU.ArticleID AS ArtikelID, PU.Menge, PU.CreationDate AS Anlage_, @userid AS AnlageUserID_, @userid AS UserID_
    FROM (
      SELECT DISTINCT _PackageUnitCIT.VPSPoID, _PackageUnitCIT.VPSKoID, _PackageUnitCIT.ArticleID, _PackageUnitCIT.Menge, _PackageUnitCIT.CreationDate
      FROM _PackageUnitCIT
      JOIN Artikel ON _PackageUnitCIT.ArticleID = Artikel.ID
    ) AS PU;

    UPDATE EinzHist SET LastVpsPoID = _PackageUnitCIT.VPSPoID
    FROM _PackageUnitCIT
    WHERE _PackageUnitCIT.EinzHistID = EinzHist.ID
      AND _PackageUnitCIT.IsLatestVPS = 1;

    INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, VPSPoID, AnlageUserID_, UserID_)
    SELECT _PackageUnitCIT.EinzHistID, _PackageUnitCIT.EinzTeilID, _PackageUnitCIT.CreationDate, 126 AS ActionsID, 250 AS ZielNrID, @arbplatzid AS ArbPlatzID, _PackageUnitCIT.VPSPoID, @userid AS AnlageUserID_, @userid AS UserID_
    FROM _PackageUnitCIT
  
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

GO