SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @statusmsg nvarchar(max), @starttime datetime, @overallstarttime datetime = GETDATE();

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Neue Scans-Tabelle erstellen                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating new SCANS-Table';
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

DROP TABLE IF EXISTS SCANS_NEW;

CREATE TABLE [dbo].[SCANS_NEW](
	[ID] [bigint] NOT NULL,
	[EinzHistID] [bigint] NOT NULL,
	[EinzTeilID] [bigint] NOT NULL,
	[DateTime] [datetime2](3) NULL,
	[ActionsID] [bigint] NOT NULL,
	[ZielNrID] [bigint] NOT NULL,
	[ArbPlatzID] [bigint] NOT NULL,
	[Menge] [int] NOT NULL,
	[LsPoID] [bigint] NOT NULL,
	[LotID] [bigint] NOT NULL,
	[WaschChID] [bigint] NOT NULL,
	[EinAusDat] [date] NULL,
	[VPSPoID] [bigint] NOT NULL,
	[LastPoolTraegerID] [bigint] NOT NULL,
	[Info] [nvarchar](240) NULL,
	[GrundID] [bigint] NOT NULL,
	[AnfPoID] [bigint] NOT NULL,
	[EingAnfPoID] [bigint] NOT NULL,
	[OpEtiKoID] [bigint] NOT NULL,
	[VonLagerBewID] [bigint] NOT NULL,
	[NachLagerBewID] [bigint] NOT NULL,
	[InvPoID] [bigint] NOT NULL,
	[TraegerID] [bigint] NOT NULL,
	[ContainID] [bigint] NOT NULL,
	[VsaID] [bigint] NOT NULL,
	[FahrtID] [bigint] NOT NULL,
	[Anlage_] [datetime2](3) NULL,
	[Update_] [datetime2](3) NULL,
	[AnlageUserID_] [integer] NULL,
	[UserID_] [integer] NULL
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Daten in neue Tabelle übernehmen                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Copying data from old table to new SCANS-Table';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

INSERT INTO SCANS_New WITH (TABLOCK) (ID, EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, LotID, WaschChID, EinAusDat, VPSPoID, LastPoolTraegerID, Info, GrundID, AnfPoID, EingAnfPoID, OpEtiKoID, VonLagerBewID, NachLagerBewID, InvPoID, TraegerID, ContainID, VsaID, FahrtID, Anlage_, Update_, AnlageUserID_, UserID_)
SELECT ID, EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, LotID, WaschChID, EinAusDat, VPSPoID, LastPoolTraegerID, Info, GrundID, AnfPoID, EingAnfPoID, OpEtiKoID, VonLagerBewID, NachLagerBewID, InvPoID, TraegerID, ContainID, VsaID, FahrtID, Anlage_, Update_, AnlageUserID_, UserID_
FROM SCANS /* WITH (INDEX(PK_Scans)) */;

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Copied all rows in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Alte Tabelle löschen, neue Tabelle umbenennen                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Dropping old SCANS-Table and renaming new table';
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

DROP TABLE SCANS;

EXECUTE sp_rename N'SCANS_NEW', N'SCANS', 'OBJECT';


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ RI-Regeln erstellen                                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating RI rules';
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_TraegerIDDefault DEFAULT -1 FOR "TraegerID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_OpEtiKoIDDefault DEFAULT -1 FOR "OpEtiKoID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_EinzTeilIDDefault DEFAULT -1 FOR "EinzTeilID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_WaschChIDDefault DEFAULT -1 FOR "WaschChID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_FahrtIDDefault DEFAULT -1 FOR "FahrtID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_GrundIDDefault DEFAULT -1 FOR "GrundID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_VPSPoIDDefault DEFAULT -1 FOR "VPSPoID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_LastPoolTraegerIDDefault DEFAULT -1 FOR "LastPoolTraegerID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_ZielNrIDDefault DEFAULT -1 FOR "ZielNrID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_LsPoIDDefault DEFAULT -1 FOR "LsPoID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_LotIDDefault DEFAULT -1 FOR "LotID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_InvPoIDDefault DEFAULT -1 FOR "InvPoID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_NachLagerBewIDDefault DEFAULT -1 FOR "NachLagerBewID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_ActionsIDDefault DEFAULT -1 FOR "ActionsID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_EinzHistIDDefault DEFAULT -1 FOR "EinzHistID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_VonLagerBewIDDefault DEFAULT -1 FOR "VonLagerBewID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_AnfPoIDDefault DEFAULT -1 FOR "AnfPoID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_VsaIDDefault DEFAULT -1 FOR "VsaID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_EingAnfPoIDDefault DEFAULT -1 FOR "EingAnfPoID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_ArbPlatzIDDefault DEFAULT -1 FOR "ArbPlatzID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_ContainIDDefault DEFAULT -1 FOR "ContainID"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_Update_Default DEFAULT GetDate() FOR "Update_"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_MengeDefault DEFAULT 0 FOR "Menge"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_Anlage_Default DEFAULT GetDate() FOR "Anlage_"
ALTER TABLE SCANS WITH NOCHECK ADD CONSTRAINT SCANS_IDDefault DEFAULT (NEXT VALUE FOR NEXTID_SCANS) FOR ID

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating primary key constraint';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

ALTER TABLE SCANS ADD CONSTRAINT PK_SCANS PRIMARY KEY NONCLUSTERED (ID);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created primary key in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': All done after ' + FORMAT(GETDATE() - @overallstarttime, N'HH:mm:ss') + N' - continue with indexes in multiple sessions';
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Indexe erstellen                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Block 1                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @statusmsg nvarchar(max), @starttime datetime, @overallstarttime datetime = GETDATE();

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating Index ActionsID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "ActionsID" ON SCANS ("ActionsID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index AnfPoID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "AnfPoID" ON SCANS ("AnfPoID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index ArbPlatzID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "ArbPlatzID" ON SCANS ("ArbPlatzID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index ContainID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "ContainID" ON SCANS ("ContainID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index DateTime';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "DateTime" ON SCANS ("DateTime","ZielNrID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N'Index creation - Block 1 - completed after ' + FORMAT(GETDATE() - @overallstarttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

GO
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Block 2                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @statusmsg nvarchar(max), @starttime datetime, @overallstarttime datetime = GETDATE();

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating Index EingAnfPoID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "EingAnfPoID" ON SCANS ("EingAnfPoID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index EinzHistID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "EinzHistID" ON SCANS ("EinzHistID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index EinzTeilID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "EinzTeilID" ON SCANS ("EinzTeilID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index FahrtID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "FahrtID" ON SCANS ("FahrtID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index GrundID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "GrundID" ON SCANS ("GrundID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N'Index creation - Block 2 - completed after ' + FORMAT(GETDATE() - @overallstarttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

GO
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Block 3                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @statusmsg nvarchar(max), @starttime datetime, @overallstarttime datetime = GETDATE();

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating Index InvPoID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "InvPoID" ON SCANS ("InvPoID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index LastPoolTraegerID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "LastPoolTraegerID" ON SCANS ("LastPoolTraegerID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index LotID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "LotID" ON SCANS ("LotID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index LsPoID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "LsPoID" ON SCANS ("LsPoID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index NachLagerBewID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "NachLagerBewID" ON SCANS ("NachLagerBewID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N'Index creation - Block 3 - completed after ' + FORMAT(GETDATE() - @overallstarttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

GO
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Block 4                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @statusmsg nvarchar(max), @starttime datetime, @overallstarttime datetime = GETDATE();

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating Index OPEtiKoID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "OpEtiKoID" ON SCANS ("OpEtiKoID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index TeilZeitpunkt';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "TeilZeitpunkt" ON SCANS ("EinzHistID","DateTime")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index TraegerID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "TraegerID" ON SCANS ("TraegerID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index VPSPoID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "VPSPoID" ON SCANS ("VPSPoID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index VonLagerBewID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "VonLagerBewID" ON SCANS ("VonLagerBewID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N'Index creation - Block 4 - completed after ' + FORMAT(GETDATE() - @overallstarttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

GO
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Block 5                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @statusmsg nvarchar(max), @starttime datetime, @overallstarttime datetime = GETDATE();

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Creating Index VsaID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "VsaID" ON SCANS ("VsaID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index WaschChID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "WaschChID" ON SCANS ("WaschChID")  WITH (FILLFACTOR = 100);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss') + N' - now creating Index ZielNrID';
SET @starttime = GETDATE();
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

CREATE INDEX "ZielNrID" ON SCANS ("ZielNrID")  WITH (FILLFACTOR = 100, DATA_COMPRESSION = PAGE);

SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Created index in ' + FORMAT(GETDATE() - @starttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;
SET @statusmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N'Index creation - Block 5 - completed after ' + FORMAT(GETDATE() - @overallstarttime, N'HH:mm:ss');
RAISERROR(@statusmsg, 0, 1) WITH NOWAIT;

GO