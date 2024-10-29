USE AWSInvest;
GO

IF OBJECT_ID('ACDOCA') IS NULL
  CREATE TABLE ACDOCA (
    ID int IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
    RBUKRS smallint,
    GJAHR smallint,
    BELNR bigint,
    DOCLN nchar(6),
    RYEAR smallint,
    CLOSINGSTEP tinyint,
    AWORG smallint,
    AWREF nchar(10),
    XREVERSING nchar(1),
    XREVERSED nchar(1),
    AWTYP_REV nchar(4),
    AWORG_REV smallint,
    AWREF_REV nchar(10),
    RTCUR nchar(3),
    RWCUR nchar(3),
    RHCUR nchar(3),
    RKCUR nchar(3),
    RFCCUR nchar(3),
    RACCT nchar(6),
    RCNTR tinyint,
    RBUSA nchar(4),
    KOKRS smallint,
    SBUSA nchar(4),
    RASSC smallint,
    TSL money,
    WSL money,
    WSL2 money,
    WSL3 money,
    HSL money,
    KSL money,
    FCSL money,
    DRCRK nchar(1),
    POPER tinyint,
    FISCYEARPER nchar(8),
    BUDAT date,
    BLDAT date,
    BLART nchar(2),
    BUZEI tinyint,
    ZUONR nvarchar(20),
    BSCHL tinyint,
    USNAM nvarchar(10),
    [TIMESTAMP] datetime2,
    RHOART tinyint,
    KTOPL nchar(3),
    REBZG nchar(10),
    REBZJ smallint,
    REBZZ tinyint,
    REBZT nchar(1),
    SGTXT nvarchar(100),
    LIFNR int,
    WWERT date,
    KOART nchar(1),
    MWSKZ nchar(2),
    VALUT date,
    XOPVW nchar(1),
    AUGDT date,
    AUGBL int,
    AUGGJ smallint,
    GKONT nchar(6),
    GKOAR nchar(1)
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO ACDOCA (RBUKRS, GJAHR, BELNR, DOCLN, RYEAR, CLOSINGSTEP, AWORG, AWREF, XREVERSING, XREVERSED, AWTYP_REV, AWORG_REV, AWREF_REV, RTCUR, RWCUR, RHCUR, RKCUR, RFCCUR, RACCT, RCNTR, RBUSA, KOKRS, SBUSA, RASSC, TSL, WSL, WSL2, WSL3, HSL, KSL, FCSL, DRCRK, POPER, FISCYEARPER, BUDAT, BLDAT, BLART, BUZEI, ZUONR, BSCHL, USNAM, [TIMESTAMP], RHOART, KTOPL, REBZG, REBZJ, REBZZ, REBZT, SGTXT, LIFNR, WWERT, KOART, MWSKZ, VALUT, XOPVW, AUGDT, AUGBL, AUGGJ, GKONT, GKOAR)
    SELECT CAST(RBUKRS AS smallint),
      CAST(GJAHR AS smallint),
      CAST(BELNR AS bigint),
      CAST(DOCLN AS nchar(6)),
      CAST(RYEAR AS smallint),
      CAST(CLOSINGSTEP AS tinyint),
      CAST(AWORG AS smallint),
      CAST(AWREF AS nchar(10)),
      CAST(XREVERSING AS nchar(1)),
      CAST(XREVERSED AS nchar(1)),
      CAST(AWTYP_REV AS nchar(4)),
      CAST(AWORG_REV AS smallint),
      CAST(AWREF_REV AS nchar(10)),
      CAST(RTCUR AS nchar(3)),
      CAST(RWCUR AS nchar(3)),
      CAST(RHCUR AS nchar(3)),
      CAST(RKCUR AS nchar(3)),
      CAST(RFCCUR AS nchar(3)),
      CAST(RACCT AS nchar(6)),
      CAST(RCNTR AS tinyint),
      CAST(RBUSA AS nchar(4)),
      CAST(KOKRS AS smallint),
      CAST(SBUSA AS nchar(4)),
      CAST(RASSC AS smallint),
      CAST(REPLACE(REPLACE(TSL, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(WSL, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(WSL2, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(WSL3, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(HSL, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(KSL, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(FCSL, N',', N'.'), N' ', N'') AS money),
      CAST(DRCRK AS nchar(1)),
      CAST(POPER AS tinyint),
      CAST(FISCYEARPER AS nchar(8)),
      CONVERT(date, BUDAT, 104),
      CONVERT(date, BLDAT, 104),
      CAST(BLART AS nchar(2)),
      CAST(BUZEI AS tinyint),
      CAST(ZUONR AS nvarchar(20)),
      CAST(BSCHL AS tinyint),
      CAST(USNAM AS nvarchar(10)),
      CONVERT(datetime2, [TIMESTAMP], 104),
      CAST(RHOART AS tinyint),
      CAST(KTOPL AS nchar(3)),
      CAST(REBZG AS bigint),
      CAST(REBZJ AS smallint),
      CAST(REBZZ AS tinyint),
      CAST(REBZT AS nchar(1)),
      CAST(SGTXT AS nvarchar(100)),
      CAST(LIFNR AS int),
      CONVERT(date, WWERT, 104),
      CAST(KOART AS nchar(1)),
      CAST(MWSKZ AS nchar(2)),
      CONVERT(date, VALUT, 104),
      CAST(XOPVW AS nchar(1)),
      CONVERT(date, AUGDT, 104),
      CAST(AUGBL AS int),
      CAST(AUGGJ AS smallint),
      CAST(GKONT AS nchar(6)),
      CAST(GKOAR AS nchar(1))
    FROM ACDOCA_Import;

    DROP TABLE ACDOCA_Import;
  
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