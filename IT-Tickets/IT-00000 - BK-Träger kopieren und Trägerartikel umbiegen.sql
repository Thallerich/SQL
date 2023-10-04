DECLARE @KdNr int = 10006829;
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @VsaMap TABLE (
  Src_VsaID int,
  Src_VsaNr int,
  Dst_VsaID int,
  Dst_VsaNr int
);

INSERT INTO @VsaMap (Src_VsaNr, Dst_VsaNr)
VALUES (3, 11), (5, 10), (6, 10), (7, 10);

UPDATE @VsaMap SET Src_VsaID = Vsa.ID
FROM Vsa
WHERE Vsa.VsaNr = [@VsaMap].Src_VsaNr
  AND Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @KdNr);

UPDATE @VsaMap SET Dst_VsaID = Vsa.ID
FROM Vsa
WHERE Vsa.VsaNr = [@VsaMap].Dst_VsaNr
  AND Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @KdNr);

DROP TABLE IF EXISTS #CopyTraeger;

CREATE TABLE #CopyTraeger (
  Src_TraegerID int,
  Dst_TraegerID int,
  Dst_VsaID int,
  Dst_TraegerNr varchar(8) COLLATE Latin1_General_CS_AS
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO Traeger (VsaID, [Status], Traeger, Altenheim, AbteilID, PersNr, Titel, Vorname, Nachname, Namenschild1, Namenschild2, Namenschild3, Namenschild4, Geschlecht, Indienst, Ausdienst, IndienstDat, AusdienstDat, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.VsaID, inserted.Traeger
    INTO #CopyTraeger (Dst_TraegerID, Dst_VsaID, Dst_TraegerNr)
    SELECT VsaMap.Dst_VsaID, Traeger.[Status], STUFF(Traeger.Traeger, 1, 1, N'9'), Traeger.Altenheim, Traeger.AbteilID, Traeger.PersNr, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Traeger.Namenschild1, Traeger.Namenschild2, Traeger.Namenschild3, Traeger.Namenschild4, Traeger.Geschlecht, Traeger.Indienst, Traeger.Ausdienst, Traeger.IndienstDat, Traeger.AusdienstDat, @UserID, @UserID
    FROM Traeger
    JOIN @VsaMap VsaMap ON Traeger.VsaID = VsaMap.Src_VsaID;

    UPDATE #CopyTraeger SET Src_TraegerID = Traeger.ID
    FROM Traeger
    JOIN @VsaMap VsaMap ON Traeger.VsaID = VsaMap.Src_VsaID
    WHERE Traeger.Traeger = STUFF(#CopyTraeger.Dst_TraegerNr, 1, 1, N'0');

    UPDATE TraeArti SET TraegerID = #CopyTraeger.Dst_TraegerID, VsaID = #CopyTraeger.Dst_VsaID
    FROM #CopyTraeger
    WHERE #CopyTraeger.Src_TraegerID = TraeArti.TraegerID;
  
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

DROP TABLE #CopyTraeger;

GO