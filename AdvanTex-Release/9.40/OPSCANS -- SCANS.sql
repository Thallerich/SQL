SET STATISTICS TIME ON;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ SCANS-Tabelle anpassen                                                                                                    ++ */
/* ++   Dauer: 1 Stunde                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TRIGGER RI_SCANS_INSERT;
DROP TRIGGER RI_SCANS_UPDATE;
GO

ALTER TABLE SCANS
  ADD EinzTeilID INTEGER NOT NULL CONSTRAINT [SCANS_EinzTeilIDDefault] Default(-1),
      ArbPlatzID INTEGER NOT NULL CONSTRAINT [SCANS_ArbPlatzIDDefault] Default(-1),
      GrundID INTEGER NOT NULL CONSTRAINT [SCANS_GrundIDDefault] Default(-1),
      AnfPoID INTEGER NOT NULL CONSTRAINT [SCANS_AnfPoIDDefault] Default(-1),
      EingAnfPoID INTEGER NOT NULL CONSTRAINT [SCANS_EingAnfPoIDDefault] Default(-1),
      OpEtiKoID INTEGER NOT NULL CONSTRAINT [SCANS_OpEtiKoIDDefault] Default(-1),
      VonLagerBewID INTEGER NOT NULL CONSTRAINT [SCANS_VonLagerBewIDDefault] Default(-1),
      NachLagerBewID INTEGER NOT NULL CONSTRAINT [SCANS_NachLagerBewIDDefault] Default(-1),
      InvPoID INTEGER NOT NULL CONSTRAINT [SCANS_InvPoIDDefault] Default(-1),
      TraegerID INTEGER NOT NULL CONSTRAINT [SCANS_TraegerIDDefault] Default(-1),
      ContainID INTEGER NOT NULL CONSTRAINT [SCANS_ContainIDDefault] Default(-1),
      VsaID INTEGER NOT NULL CONSTRAINT [SCANS_VsaIDDefault] Default(-1),
      AltOpScansID INTEGER NULL;

GO

DROP TABLE IF EXISTS SCANS_NEW;
GO

CREATE TABLE SCANS_NEW (
  ID bigint NOT NULL,
  TeileID int NOT NULL,
  EinzTeilID int NOT NULL,
  [DATETIME] datetime2(3),
  ActionsID int NOT NULL,
  ZielNrID int NOT NULL,
  ArbPlatzID int NOT NULL,
  Menge int NOT NULL,
  LsPoID int NOT NULL,
  LotID int NOT NULL,
  WaschChID int NOT NULL,
  EinAusDat date,
  VPSPoID int NOT NULL,
  LastPoolTraegerID int NOT NULL,
  Info nvarchar(max) COLLATE Latin1_General_CS_AS,
  GrundID int NOT NULL,
  AnfPoID int NOT NULL,
  EingAnfPoID int NOT NULL,
  OpEtiKoID int NOT NULL,
  VonLagerBewID int NOT NULL,
  NachLagerBewID int NOT NULL,
  InvPoID int NOT NULL,
  TraegerID int NOT NULL,
  ContainID int NOT NULL,
  VsaID int NOT NULL,
  AltOpScansID int NULL,
  Anlage_ datetime2(3),
  Update_ datetime2(3),
  AnlageUserID_ int,
  UserID_ int
);

GO

INSERT INTO SCANS_NEW (ID, TeileID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, LotID, WaschChID, EinAusDat, VPSPoID, LastPoolTraegerID, Info, GrundID, AnfPoID, EingAnfPoID, OpEtiKoID, VonLagerBewID, NachLagerBewID, InvPoID, TraegerID, ContainID, VsaID, AltOpScansID, Anlage_, Update_, AnlageUserID_, UserID_)
SELECT ID, TeileID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, LotID, WaschChID, EinAusDat, VPSPoID, LastPoolTraegerID, Info, GrundID, AnfPoID, EingAnfPoID, OpEtiKoID, VonLagerBewID, NachLagerBewID, InvPoID, TraegerID, ContainID, VsaID, AltOpScansID, Anlage_, Update_, AnlageUserID_, UserID_
FROM SCANS;

GO

/* ALTER TABLE SCANS
  DROP CONSTRAINT SCANS_ActionsIDDefault,
                  SCANS_Anlage_Default,
                  SCANS_IDDefault,
                  SCANS_LastPoolTraegerIDDefault,
                  SCANS_LotIDDefault,
                  SCANS_LsPoIDDefault,
                  SCANS_MengeDefault,
                  SCANS_TeileIDDefault,
                  SCANS_Update_Default,
                  SCANS_VPSPoIDDefault,
                  SCANS_WaschChIDDefault,
                  SCANS_ZielNrIDDefault,
                  ri_DD_SCANS_LastPoolTraegerID,
                  ri_DD_SCANS_ActionsID,
                  ri_DD_SCANS_LotID,
                  SCANS_EinzTeilIDDefault,
                  SCANS_ArbPlatzIDDefault,
                  SCANS_GrundIDDefault,
                  SCANS_AnfPoIDDefault,
                  SCANS_EingAnfPoIDDefault,
                  SCANS_OpEtiKoIDDefault,
                  SCANS_VonLagerBewIDDefault,
                  SCANS_NachLagerBewIDDefault,
                  SCANS_InvPoIDDefault,
                  SCANS_TraegerIDDefault,
                  SCANS_ContainIDDefault,
                  SCANS_VsaIDDefault,
                  ri_DD_SCANS_TeileID;

GO */

DROP TABLE SCANS;
GO
EXECUTE sp_rename N'SCANS_NEW', N'SCANS', 'OBJECT';
GO

ALTER TABLE SCANS
  ADD CONSTRAINT SCANS_ActionsIDDefault DEFAULT -1 FOR ActionsID,
      CONSTRAINT SCANS_AnfPoIDDefault DEFAULT -1 FOR AnfPoID,
      CONSTRAINT SCANS_Anlage_Default DEFAULT GetDate() FOR Anlage_,
      CONSTRAINT SCANS_ArbPlatzIDDefault DEFAULT -1 FOR ArbPlatzID,
      CONSTRAINT SCANS_ContainIDDefault DEFAULT -1 FOR ContainID,
      CONSTRAINT SCANS_EingAnfPoIDDefault DEFAULT -1 FOR EingAnfPoID,
      CONSTRAINT SCANS_EinzTeilIDDefault DEFAULT -1 FOR EinzTeilID,
      CONSTRAINT SCANS_GrundIDDefault DEFAULT -1 FOR GrundID,
      CONSTRAINT SCANS_IDDefault DEFAULT NEXT VALUE FOR NextID_SCANS FOR ID,
      CONSTRAINT SCANS_InvPoIDDefault DEFAULT -1 FOR InvPoID,
      CONSTRAINT SCANS_LastPoolTraegerIDDefault DEFAULT -1 FOR LastPoolTraegerID,
      CONSTRAINT SCANS_LotIDDefault DEFAULT -1 FOR LotID,
      CONSTRAINT SCANS_LsPoIDDefault DEFAULT -1 FOR LsPoID,
      CONSTRAINT SCANS_MengeDefault DEFAULT 0 FOR Menge,
      CONSTRAINT SCANS_NachLagerBewIDDefault DEFAULT -1 FOR NachLagerBewID,
      CONSTRAINT SCANS_OpEtiKoIDDefault DEFAULT -1 FOR OpEtiKoID,
      CONSTRAINT SCANS_TeileIDDefault DEFAULT -1 FOR TeileID,
      CONSTRAINT SCANS_TraegerIDDefault DEFAULT -1 FOR TraegerID,
      CONSTRAINT SCANS_Update_Default DEFAULT GetDate() FOR Update_,
      CONSTRAINT SCANS_VPSPoIDDefault DEFAULT -1 FOR VPSPoID,
      CONSTRAINT SCANS_VonLagerBewIDDefault DEFAULT -1 FOR VonLagerBewID,
      CONSTRAINT SCANS_VsaIDDefault DEFAULT -1 FOR VsaID,
      CONSTRAINT SCANS_WaschChIDDefault DEFAULT -1 FOR WaschChID,
      CONSTRAINT SCANS_ZielNrIDDefault DEFAULT -1 FOR ZielNrID;

GO

ALTER TABLE SCANS
  ADD CONSTRAINT PK_SCANS PRIMARY KEY NONCLUSTERED (ID);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ OPSCANS -> SCANS                                                                                                          ++ */
/* ++   Dauer: 3 Stunden                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @AnzOpScans int = 200000;
DECLARE @MaxID int = (SELECT MAX(ID) FROM OPSCANS);
DECLARE @cMinID int = ISNULL((SELECT MAX(AltOpScansID) FROM Scans WHERE AltOpScansID IS NOT NULL), 0) + 1;
DECLARE @cMaxID int;
DECLARE @Runs int;

-- Wenn Max(AltOpScansID) nicht gefüllt ist, dann wird @cMinID = 1
-- Wir können aber mit der kleinsten OpScans.ID anfangen
IF (@cMinID = 1) BEGIN
  SET @cMinID = ISNULL((SELECT MIN(ID) FROM OpScans WHERE ID > 0), 1);
END;

SET @cMaxID = @cMinID + @AnzOpScans - 1;

-- wenn @cMinID endgültig feststeht, dann die Durchläufe ermitteln
SET @Runs = ((@MaxID - @cMinID) / @AnzOpScans) + 1;

WHILE (@Runs > 0) BEGIN
  BEGIN TRANSACTION;
    INSERT INTO Scans ([DateTime], EinzTeilID, ZielNrID, ActionsID, GrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OpEtiKoID, VonLagerBewID, InvPoID, NachLagerBewID, TraegerID, ContainID, LsPoID, VsaID, AltOpScansID, Anlage_, AnlageUserID_, UserID_)
    SELECT OPScans.Zeitpunkt, OPScans.OpTeileID, OPScans.ZielNrID, OPScans.ActionsID, OPScans.OpGrundID, OPScans.AnfPoID, OPScans.ArbPlatzID, OPScans.VPSPoID, OPScans.EingAnfPoID, OPScans.Menge, OPScans.OpEtiKoID, OPScans.VonLagerBewID, OPScans.InvPoID, OPScans.NachLagerBewID, OPScans.TraegerID, OPScans.ContainID, OPScans.LsPoID, OPScans.VsaID, OPScans.ID AltOPScansID, OPScans.Anlage_, OPScans.AnlageUserID_, OPScans.UserID_
    FROM OPScans
    WHERE OPScans.ID > 0
      AND OPScans.ID BETWEEN @cMinID AND @cMaxID
      AND NOT EXISTS (
        SELECT InvPo.ID
        FROM InvPo
        WHERE InvPo.OPScansID > 0
          AND OPScans.ID = InvPo.OPScansID
      )
    ORDER BY OPScans.ID;
      
    SET @cMinID = @cMinID + @AnzOpScans;
    SET @cMaxID = @cMaxID + @AnzOpScans;
    SET @Runs = @Runs - 1;
  COMMIT TRANSACTION;
END;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Index anlegen                                                                                                             ++ */
/* ++   Dauer: 5 Stunden                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* TODO: Parallellisieren! */

CREATE INDEX ActionsID ON SCANS (ActionsID) WITH (FILLFACTOR = 100);
CREATE INDEX AltOpScansID ON SCANS (AltOpScansID) WITH (FILLFACTOR = 100);
CREATE INDEX AnfPoID ON SCANS (AnfPoID) WITH (FILLFACTOR = 100);
CREATE INDEX ArbPlatzID ON SCANS (ArbPlatzID) WITH (FILLFACTOR = 100);
CREATE INDEX ContainID ON SCANS (ContainID) WITH (FILLFACTOR = 100);
CREATE INDEX [DateTime] ON SCANS ([DateTime],ZielNrID) WITH (FILLFACTOR = 100);
CREATE INDEX EingAnfPoID ON SCANS (EingAnfPoID) WITH (FILLFACTOR = 100);
CREATE INDEX EinzTeilID ON SCANS (EinzTeilID) WITH (FILLFACTOR = 100);
CREATE INDEX GrundID ON SCANS (GrundID) WITH (FILLFACTOR = 100);
CREATE INDEX InvPoID ON SCANS (InvPoID) WITH (FILLFACTOR = 100);
CREATE INDEX LastPoolTraegerID ON SCANS (LastPoolTraegerID) WITH (FILLFACTOR = 100);
CREATE INDEX LotID ON SCANS (LotID) WITH (FILLFACTOR = 100);
CREATE INDEX LsPoID ON SCANS (LsPoID) WITH (FILLFACTOR = 100);
CREATE INDEX NachLagerBewID ON SCANS (NachLagerBewID) WITH (FILLFACTOR = 100);
CREATE INDEX OpEtiKoID ON SCANS (OpEtiKoID) WITH (FILLFACTOR = 100);
CREATE INDEX TeilZeitpunkt ON SCANS (TeileID,DateTime) WITH (FILLFACTOR = 100);
CREATE INDEX TeileID ON SCANS (TeileID) WITH (FILLFACTOR = 100);
CREATE INDEX TraegerID ON SCANS (TraegerID) WITH (FILLFACTOR = 100);
CREATE INDEX VPSPoID ON SCANS (VPSPoID) WITH (FILLFACTOR = 100);
CREATE INDEX VonLagerBewID ON SCANS (VonLagerBewID) WITH (FILLFACTOR = 100);
CREATE INDEX VsaID ON SCANS (VsaID) WITH (FILLFACTOR = 100);
CREATE INDEX WaschChID ON SCANS (WaschChID) WITH (FILLFACTOR = 100);
CREATE INDEX ZielNrID ON SCANS (ZielNrID) WITH (FILLFACTOR = 100);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ RI-Constraints anlegen                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

ALTER TABLE SCANS WITH CHECK
  ADD CONSTRAINT ri_DD_SCANS_LotID FOREIGN KEY (LotID) REFERENCES LOT(ID) ON UPDATE CASCADE ON DELETE NO ACTION,
      CONSTRAINT ri_DD_SCANS_LastPoolTraegerID FOREIGN KEY (LastPoolTraegerID) REFERENCES TRAEGER(ID) ON UPDATE CASCADE ON DELETE NO ACTION,
      CONSTRAINT ri_DD_SCANS_GrundID FOREIGN KEY (GrundID) REFERENCES WEGGRUND(ID) ON UPDATE CASCADE ON DELETE NO ACTION,
      CONSTRAINT ri_DD_SCANS_InvPoID FOREIGN KEY (InvPoID) REFERENCES INVPO(ID) ON UPDATE CASCADE ON DELETE NO ACTION,
      CONSTRAINT ri_DD_SCANS_ActionsID FOREIGN KEY (ActionsID) REFERENCES ACTIONS(ID) ON UPDATE CASCADE ON DELETE NO ACTION;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Trigger anlegen                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE TRIGGER "AnlageUser_SCANS_INSERT" ON SCANS AFTER INSERT AS SET NOCOUNT ON; 
DECLARE @UserID Int; 
IF dbo.TriggerAnlageEnabled() = 1 BEGIN 
  IF OBJECT_ID('tempdb..#AdvSession') IS NOT NULL 
    SET @UserID = COALESCE((SELECT TOP 1 MitarbeiID FROM #AdvSession ORDER BY 1), -2) 
  ELSE 
    SET @UserID = -2 
 
  UPDATE SCANS 
  SET AnlageUserID_ = COALESCE(INSERTED.AnlageUserID_, @UserID), UserID_ = COALESCE(INSERTED.AnlageUserID_, @UserID) 
  FROM INSERTED 
  WHERE INSERTED.ID = SCANS.ID END;

GO
CREATE TRIGGER "LastModified_SCANS_UPDATE" ON SCANS AFTER UPDATE AS SET NOCOUNT ON; 
DECLARE @UserID Int; 
IF (dbo.TriggerUpdateEnabled() = 1) BEGIN 
  IF UPDATE(Update_) BEGIN 
    RAISERROR('<ADV> Updating the field SCANS.Update_ manually is not allowed. TRANSACTION rolled back.', 16, 1); 
    ROLLBACK TRANSACTION
    RETURN
  END
  IF (UPDATE(UserID_)) 
    SET @UserID = (SELECT TOP 1 UserID_ FROM Inserted ORDER BY 1) 
  ELSE  BEGIN 
    IF OBJECT_ID('tempdb..#AdvSession') IS NOT NULL 
      SET @UserID = COALESCE((SELECT TOP 1 MitarbeiID FROM #AdvSession ORDER BY 1), -2) 
    ELSE 
      SET @UserID = -2 
  END 
 
  UPDATE SCANS 
  SET Update_ = GetDate(), 
  UserID_ = @UserID 
  FROM INSERTED 
  WHERE INSERTED.ID = SCANS.ID END;

GO
CREATE TRIGGER RI_SCANS_INSERT ON SCANS FOR INSERT
AS BEGIN 
SET NOCOUNT ON 
IF (dbo.TriggerRIenabled() = 0) 
  RETURN;
DECLARE @numrows int 
SET @numrows = (SELECT COUNT(*) FROM inserted) 

IF UPDATE(AnfPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ANFPO JOIN inserted AS I 
ON ANFPO.ID = I.AnfPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.AnfPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(ArbPlatzID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ARBPLATZ JOIN inserted AS I 
ON ARBPLATZ.ID = I.ArbPlatzID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.ArbPlatzID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(ContainID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM CONTAIN JOIN inserted AS I 
ON CONTAIN.ID = I.ContainID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.ContainID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(EingAnfPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ANFPO JOIN inserted AS I 
ON ANFPO.ID = I.EingAnfPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.EingAnfPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(EinzTeilID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM OPTEILE JOIN inserted AS I 
ON OPTEILE.ID = I.EinzTeilID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.EinzTeilID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(LsPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM LSPO JOIN inserted AS I 
ON LSPO.ID = I.LsPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.LsPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(NachLagerBewID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM LAGERBEW JOIN inserted AS I 
ON LAGERBEW.ID = I.NachLagerBewID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.NachLagerBewID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(OpEtiKoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM OPETIKO JOIN inserted AS I 
ON OPETIKO.ID = I.OpEtiKoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.OpEtiKoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(TeileID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM TEILE JOIN inserted AS I 
ON TEILE.ID = I.TeileID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.TeileID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(TraegerID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM TRAEGER JOIN inserted AS I 
ON TRAEGER.ID = I.TraegerID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.TraegerID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(VonLagerBewID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM LAGERBEW JOIN inserted AS I 
ON LAGERBEW.ID = I.VonLagerBewID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.VonLagerBewID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(VPSPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM VPSPO JOIN inserted AS I 
ON VPSPO.ID = I.VPSPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.VPSPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(VsaID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM VSA JOIN inserted AS I 
ON VSA.ID = I.VsaID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.VsaID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(WaschChID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM WASCHCH JOIN inserted AS I 
ON WASCHCH.ID = I.WaschChID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.WaschChID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(ZielNrID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ZIELNR JOIN inserted AS I 
ON ZIELNR.ID = I.ZielNrID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.ZielNrID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

END;

GO
CREATE TRIGGER RI_SCANS_UPDATE ON SCANS FOR UPDATE
AS BEGIN 
SET NOCOUNT ON 
IF (UPDATE(Update_)) OR (dbo.TriggerRIenabled() = 0) 
  RETURN;
DECLARE @numrows int 
SET @numrows = (SELECT COUNT(*) FROM inserted) 

IF UPDATE(AnfPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ANFPO JOIN inserted AS I 
ON ANFPO.ID = I.AnfPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.AnfPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(ArbPlatzID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ARBPLATZ JOIN inserted AS I 
ON ARBPLATZ.ID = I.ArbPlatzID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.ArbPlatzID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(ContainID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM CONTAIN JOIN inserted AS I 
ON CONTAIN.ID = I.ContainID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.ContainID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(EingAnfPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ANFPO JOIN inserted AS I 
ON ANFPO.ID = I.EingAnfPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.EingAnfPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(EinzTeilID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM OPTEILE JOIN inserted AS I 
ON OPTEILE.ID = I.EinzTeilID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.EinzTeilID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(LsPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM LSPO JOIN inserted AS I 
ON LSPO.ID = I.LsPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.LsPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(NachLagerBewID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM LAGERBEW JOIN inserted AS I 
ON LAGERBEW.ID = I.NachLagerBewID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.NachLagerBewID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(OpEtiKoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM OPETIKO JOIN inserted AS I 
ON OPETIKO.ID = I.OpEtiKoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.OpEtiKoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(TeileID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM TEILE JOIN inserted AS I 
ON TEILE.ID = I.TeileID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.TeileID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(TraegerID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM TRAEGER JOIN inserted AS I 
ON TRAEGER.ID = I.TraegerID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.TraegerID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(VonLagerBewID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM LAGERBEW JOIN inserted AS I 
ON LAGERBEW.ID = I.VonLagerBewID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.VonLagerBewID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(VPSPoID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM VPSPO JOIN inserted AS I 
ON VPSPO.ID = I.VPSPoID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.VPSPoID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(VsaID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM VSA JOIN inserted AS I 
ON VSA.ID = I.VsaID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.VsaID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(WaschChID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM WASCHCH JOIN inserted AS I 
ON WASCHCH.ID = I.WaschChID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.WaschChID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

IF UPDATE(ZielNrID)  AND @numrows > 0 BEGIN 
IF @numrows <> (SELECT COUNT(*) 
FROM ZIELNR JOIN inserted AS I 
ON ZIELNR.ID = I.ZielNrID) 
BEGIN 
RAISERROR('<ADV> Result SCANS.ZielNrID for SCANS is orphaned. TRANSACTION rolled back.', 16, 1) 
ROLLBACK TRANSACTION 
RETURN 
END 
END

END;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ dbSystem anpassen                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

-- alle vorhandenen Felder aus TabField löschen (Scans)
delete from dbsystem.tabfield
where TabNameID = 10319;

-- fehlende Felder anlegen
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13461,10319,1,'ID','I',0,0,'Eindeutige Kennung','Unique identifier',NULL,NULL,0,1,NULL,0,0,0,NULL,NULL,0,0,0,0,2805,0,0,0,'-1',0,0,0,0,NULL,NULL,2003,0,NULL,0,0,0,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-01-12 17:07:54' AS DATETIME2(3)),'        ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13462,10319,2,'TeileID','i',0,0,'Verweis auf Einzelteil','Garment reference',NULL,'bei reinen OP/Pool-Teilen -1',0,1,NULL,0,0,0,'TEILE','ID',1,1,0,0,808,2,0,0,'-1',0,0,1,0,NULL,NULL,2003,0,NULL,0,0,1,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-09-10 08:59:06' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33148,10319,3,'EinzTeilID','i',0,0,'Verweis auf OPTEILE','Reference to EinzTeil',NULL,'bei reinen BK-Teilen -1',0,1,NULL,0,0,0,'OPTEILE','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:33:25' AS DATETIME2(3)),'BAKKER',CAST('2021-09-10 08:58:58' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13464,10319,4,'DateTime','d',7,0,'Zeitpunkt des Scans','Timestamp of scan',NULL,NULL,1,0,NULL,0,0,0,NULL,NULL,0,0,0,0,2721,0,0,0,NULL,0,0,0,0,NULL,NULL,2003,0,NULL,0,0,0,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:33:32' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (29687,10319,5,'ActionsID','i',0,0,'Verweis auf Actions','Actions reference',NULL,NULL,0,1,NULL,0,0,0,'ACTIONS','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,84243,0,NULL,0,0,0,NULL,CAST('2017-09-25 21:23:42' AS DATETIME2(3)),'ADVSUP',CAST('2021-09-09 11:33:32' AS DATETIME2(3)),'BAKKER  ','-1',0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (16440,10319,6,'ZielNrID','i',0,0,'Verweis auf ZielNr','Production Point reference',NULL,NULL,0,1,NULL,0,0,0,'ZIELNR','ID',1,0,0,0,29,2,0,0.079,'-1',0,0,1,0,NULL,NULL,2006,0,NULL,0,0,1,NULL,CAST('2006-06-26 14:10:21' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:33:32' AS DATETIME2(3)),'BAKKER  ','-1',0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33151,10319,7,'ArbPlatzID','i',0,0,'Verweis auf ArbPlatz','Reference to ArbPlatz',NULL,NULL,0,1,NULL,0,0,0,'ARBPLATZ','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,19296,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:35:39' AS DATETIME2(3)),'BAKKER',CAST('2021-09-10 09:09:13' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13466,10319,8,'Menge','i',0,0,'Menge','Quantity',NULL,'1: Einlesen
-1: Auslesen',0,1,NULL,0,0,1,NULL,NULL,0,0,0,0,3,0,0,0,'0',0,0,0,0,NULL,NULL,2003,0,NULL,0,0,0,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:36:58' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13467,10319,9,'LsPoID','i',0,0,'Verweis auf LsPo','Delivery Note Line reference',NULL,'bei Auslese-Scans

Wenn der Artikel den Status "betrieblich" hat, wird keine LsPo erzeugt, dann ist die LsPoID - 1 und das EinAusDat leer.',0,1,NULL,0,0,0,'LSPO','ID',1,1,0,0,195,2,0,0.078,'-1',0,0,1,0,NULL,NULL,2003,0,NULL,0,0,1,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:36:46' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (14122,10319,10,'LotID','i',0,0,'Verweis auf Produktionslot','Production Lot reference',NULL,NULL,0,1,NULL,0,0,0,'LOT','ID',1,1,0,0,5,2,0,0.062,'-1',0,0,1,0,'Select ID, RTrim(CAST(LotNr AS VARCHAR)) LotNr FROM LOT ORDER BY LotNr',NULL,2003,0,NULL,0,0,0,NULL,CAST('2003-06-24 08:31:49' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:36:46' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (14138,10319,11,'WaschChID','i',0,0,'Verweis auf Waschcharge','wash batches reference',NULL,NULL,0,1,NULL,0,0,0,'WASCHCH','ID',1,1,0,0,1,2,1,0.047,'-1',0,0,1,0,NULL,NULL,2003,0,NULL,0,0,1,NULL,CAST('2003-07-03 14:42:27' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:36:46' AS DATETIME2(3)),'BAKKER  ','-1',0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (15176,10319,12,'EinAusDat','D',0,0,'Lieferdatum','Delivery date',NULL,'bei Einlese-Scans Teile.Eingang1, bei Auslese-Scans Teile.Ausgang1

Wenn der Artikel den Status "betrieblich" hat, wird keine LsPo erzeugt, es gibt kein neues Teile.Ausgang1-Datum und das EinAusDat bleibt leer.',1,0,NULL,0,0,0,NULL,NULL,0,0,0,0,90,0,0,0,NULL,0,0,0,0,NULL,NULL,2005,0,NULL,0,0,0,NULL,CAST('2005-04-19 23:16:07' AS DATETIME2(3)),NULL,CAST('2021-09-09 11:36:46' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (20670,10319,13,'VPSPoID','i',0,0,'Verweis auf VPSPo','Packaging unit positions reference',NULL,NULL,0,1,NULL,0,0,0,'VPSPO','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,2011,0,NULL,0,0,1,NULL,CAST('2011-06-22 10:25:55' AS DATETIME2(3)),'AK',CAST('2021-09-09 11:36:46' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (26994,10319,14,'LastPoolTraegerID','i',0,0,'Verweis auf Traeger','Wearer reference',NULL,NULL,0,1,NULL,0,0,0,'TRAEGER','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,61417,0,NULL,0,0,0,NULL,CAST('2015-10-20 10:30:58' AS DATETIME2(3)),'JH',CAST('2021-09-09 11:55:19' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (29494,10319,15,'Info','W',1,0,'Zusätzliche Informationen zum Scan','Info text',NULL,NULL,0,0,NULL,0,0,0,NULL,NULL,0,0,0,0,0,2,0,0,NULL,0,0,0,0,NULL,NULL,82074,0,NULL,0,0,0,NULL,CAST('2017-07-07 20:45:09' AS DATETIME2(3)),'SL',CAST('2021-09-09 11:36:45' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33149,10319,16,'GrundID','i',0,0,'Verweis auf Grund (z.B. Nachwaschgrund)','Reference to Reason (e.g. for rewashing)',NULL,NULL,0,1,NULL,0,0,0,'WEGGRUND','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,0,NULL,CAST('2021-09-09 11:34:53' AS DATETIME2(3)),'BAKKER',CAST('2021-09-16 12:21:09' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33150,10319,17,'AnfPoID','i',0,0,'Verweis auf AnfPo','Reference to AnfPo',NULL,'Beim Auslesevorgang wird eingetragen, zu welchem Packzettel das Einzelteil gescannt wird',0,1,NULL,0,0,0,'ANFPO','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:35:06' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 12:06:14' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33153,10319,18,'EingAnfPoID','i',0,0,'Verweis auf AnfPo','Reference to AnfPo',NULL,'Für Auswertungen: 
Durch einen Einlesescan wurde die Anforderungsmenge auf dieser Anforderungsposition erhöht.',0,1,NULL,0,0,0,'ANFPO','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:36:00' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 11:53:41' AS DATETIME2(3)),'        ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33154,10319,19,'OpEtiKoID','i',0,0,'Verweis auf OpEtiKo','Reference to OpEtiKo',NULL,NULL,0,1,NULL,0,0,0,'OPETIKO','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:36:32' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 12:06:21' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33155,10319,20,'VonLagerBewID','i',0,0,'Verweis auf LagerBew','Reference to LagerBew',NULL,NULL,0,1,NULL,0,0,0,'LAGERBEW','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:37:13' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 12:06:37' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33157,10319,21,'NachLagerBewID','i',0,0,'Verweis auf LagerBew','Reference to LagerBew',NULL,NULL,0,1,NULL,0,0,0,'LAGERBEW','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:37:33' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 12:06:42' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33156,10319,22,'InvPoID','i',0,0,'Verweis auf InvPo','Reference to InvPo',NULL,NULL,0,1,NULL,0,0,0,'INVPO','ID',1,1,1,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,0,NULL,CAST('2021-09-09 11:37:24' AS DATETIME2(3)),'BAKKER',CAST('2021-09-16 10:07:50' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33158,10319,23,'TraegerID','i',0,0,'Verweis auf Traeger','Reference to Traeger',NULL,'Bei Pool-Kleidung, die an Trägern ausgegeben wird.
Bsp. Ausgabesysteme',0,1,NULL,0,0,0,'TRAEGER','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:37:56' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 12:06:50' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33159,10319,24,'ContainID','i',0,0,'Verweis auf Contain','Reference to Contain',NULL,'Wenn die Auslesung in einem bestimmten Container vorgenommen wurde, kann dies hier gespeichert werden',0,1,NULL,0,0,0,'CONTAIN','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,130237,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:38:17' AS DATETIME2(3)),'BAKKER',CAST('2021-09-09 12:06:57' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33160,10319,25,'VsaID','i',0,0,'Verweis auf Vsa','Reference to Vsa',NULL,'Wir gefüllt beim:
- Einlesen: VsaID von der das Teil kommt
- Auslesen: VsaID zu der das Teil geht',0,1,NULL,0,0,0,'VSA','ID',1,1,0,0,0,2,0,0,'-1',0,0,0,0,NULL,NULL,124060,0,NULL,0,0,1,NULL,CAST('2021-09-09 11:38:31' AS DATETIME2(3)),'BAKKER',CAST('2021-09-10 09:08:52' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (33276,10319,26,'AltOpScansID','i',0,0,'frühere OpScansID','previous OpScansID',NULL,NULL,0,0,NULL,0,0,0,NULL,NULL,0,0,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,130237,0,NULL,0,0,0,NULL,CAST('2021-12-06 15:19:52' AS DATETIME2(3)),'BAKKER',CAST('2021-12-06 15:23:26' AS DATETIME2(3)),'BAKKER  ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13468,10319,27,'Anlage_','d',7,0,'Zeitpunkt der Datensatz-Anlage','Time stamp of creation',NULL,NULL,1,0,NULL,0,0,0,NULL,NULL,0,0,0,0,2795,0,0,0,'GetDate()',0,0,0,0,NULL,NULL,2003,0,NULL,0,0,0,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-12-06 15:19:53' AS DATETIME2(3)),'        ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (13469,10319,28,'Update_','d',7,0,'Zeitpunkt der letzten Änderung','Time stamp of last modification',NULL,NULL,1,0,NULL,0,0,0,NULL,NULL,0,0,0,0,1141,0,0,0,'GetDate()',0,0,0,0,NULL,NULL,2003,0,NULL,0,0,0,NULL,CAST('2003-03-06 17:00:09' AS DATETIME2(3)),NULL,CAST('2021-12-06 15:19:53' AS DATETIME2(3)),'        ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (28042,10319,29,'AnlageUserID_','i',0,0,'Benutzer der Datensatz-Anlage','UserID of creation',NULL,NULL,1,0,NULL,0,0,0,NULL,NULL,0,1,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,78244,0,NULL,0,0,0,NULL,CAST('2017-03-31 15:00:25' AS DATETIME2(3)),'MST',CAST('2021-12-06 15:19:53' AS DATETIME2(3)),'        ',NULL,0,NULL,NULL,NULL);
INSERT INTO dbsystem.tabfield
(ID,TabNameID,Pos,Name,Type,Len,Dec,Bez,BezEN,LabelText,Comments,AllowNull,NotNullDD,Validation,Veraltet,HighlyUsed,AddValue,RefTableName,RefFieldName,RestrictDelete,AllowMinus1,Recursive,NoRecurDel,DictinctCount,RefChkMode,ChkTime0,ChkTime1,DefaultValue,BuildFTS,DynLinkToParent,DynLinkToChildren,HideOnScreen,WaehleSQL,MemoWarnung,ToDoNr,MandatoryField,PflichtbedingungSQL,AllowMinus1IfNoOtherChoice,IsMultiLangField,IgnoreRefCheckMsSQL,DomainName,Anlage_,AnlageUser_,Update_,User_,DefaultValue2,Precision,GridExpression,Test,PflichtfeldMessage) 
VALUES (28043,10319,30,'UserID_','i',0,0,'Benutzer der letzten Datensatz-Änderung','UserID of last modification',NULL,NULL,1,0,NULL,0,0,0,NULL,NULL,0,1,0,0,0,0,0,0,NULL,0,0,0,0,NULL,NULL,78244,0,NULL,0,0,0,NULL,CAST('2017-03-31 15:00:25' AS DATETIME2(3)),'MST',CAST('2021-12-06 15:19:53' AS DATETIME2(3)),'        ',NULL,0,NULL,NULL,NULL);

-- fehlende Indizes anlegen
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16481,10319,'EinzTeilID','EinzTeilID',0,NULL,CAST('2021-09-09 11:33:25' AS DATETIME2(3)),CAST('2021-09-09 11:33:25' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16482,10319,'GrundID','GrundID',0,NULL,CAST('2021-09-09 11:34:53' AS DATETIME2(3)),CAST('2021-09-16 13:30:27' AS DATETIME2(3)),'BAKKER  ','BAKKER',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16483,10319,'AnfPoID','AnfPoID',0,NULL,CAST('2021-09-09 11:35:06' AS DATETIME2(3)),CAST('2021-09-09 11:35:06' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16484,10319,'ArbPlatzID','ArbPlatzID',0,NULL,CAST('2021-09-09 11:35:39' AS DATETIME2(3)),CAST('2021-09-09 11:35:39' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16486,10319,'EingAnfPoID','EingAnfPoID',0,NULL,CAST('2021-09-09 11:36:00' AS DATETIME2(3)),CAST('2021-09-09 11:36:00' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16487,10319,'OpEtiKoID','OpEtiKoID',0,NULL,CAST('2021-09-09 11:36:32' AS DATETIME2(3)),CAST('2021-09-09 11:36:32' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16488,10319,'VonLagerBewID','VonLagerBewID',0,NULL,CAST('2021-09-09 11:37:13' AS DATETIME2(3)),CAST('2021-09-09 11:37:13' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16489,10319,'InvPoID','InvPoID',0,NULL,CAST('2021-09-09 11:37:24' AS DATETIME2(3)),CAST('2021-09-09 11:37:24' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16490,10319,'NachLagerBewID','NachLagerBewID',0,NULL,CAST('2021-09-09 11:37:33' AS DATETIME2(3)),CAST('2021-09-09 11:37:33' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16491,10319,'TraegerID','TraegerID',0,NULL,CAST('2021-09-09 11:37:56' AS DATETIME2(3)),CAST('2021-09-09 11:37:56' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16492,10319,'ContainID','ContainID',0,NULL,CAST('2021-09-09 11:38:18' AS DATETIME2(3)),CAST('2021-09-09 11:38:18' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16493,10319,'VsaID','VsaID',0,NULL,CAST('2021-09-09 11:38:31' AS DATETIME2(3)),CAST('2021-09-09 11:38:31' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);
INSERT INTO dbsystem.tabindex
(ID,TabNameID,TagName,Expression,UniqueFlag,Include,Anlage_,Update_,User_,AnlageUser_,"FillFactor",TodoNr) 
VALUES (16530,10319,'AltOpScansID','AltOpScansID',0,NULL,CAST('2021-12-06 15:22:33' AS DATETIME2(3)),CAST('2021-12-06 15:22:33' AS DATETIME2(3)),'BAKKER  ','BAKKER  ',100,130237);