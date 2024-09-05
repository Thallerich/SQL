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