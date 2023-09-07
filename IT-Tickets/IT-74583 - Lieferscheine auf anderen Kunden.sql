DROP TABLE IF EXISTS #LsNew;
GO

DECLARE @MapTable TABLE (
  KdNr_Old int,
  VsaNr_Old int,
  KdNr_New int,
  KundenID_new int,
  VsaNr_New int,
  VsaID_New int,
  AbteilID_New int,
  TourenID_New int
);

INSERT INTO @MapTable (KdNr_Old, VsaNr_Old, KdNr_New, VsaNr_New)
VALUES
  (10003461, 65, 10003460, 65),
  (10003461, 66, 10003460, 66),
  (10003461, 52, 10003460, 52),
  (10003461, 69, 10003460, 69),
  (10003466, 12, 10003465, 12),
  (10003466, 15, 10003465, 15),
  (10003466, 22, 10003465, 22),
  (10003466, 21, 10003465, 21),
  (10003466, 20, 10003465, 20),
  (10003474, 88, 10003473, 88),
  (10003474, 87, 10003473, 87),
  (10003474, 96, 10003473, 96),
  (10003474, 95, 10003473, 95),
  (10003474, 66, 10003473, 66);

UPDATE @MapTable SET VsaID_New = Vsa.ID, AbteilID_New = Vsa.AbteilID, KundenID_new = Kunden.ID
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = [@MapTable].KdNr_New
  AND Vsa.VsaNr = [@MapTable].VsaNr_New;

SELECT LsKo.ID AS LsKoID, [@MapTable].VsaID_New, LsPo.ID AS LsPoID, [@MapTable].AbteilID_New, KdArti_New.ID AS KdArtiID_New
INTO #LsNew
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN @MapTable ON Kunden.KdNr = [@MapTable].KdNr_Old AND Vsa.VsaNr = [@MapTable].VsaNr_Old
JOIN KdArti AS KdArti_New ON [@MapTable].KundenID_new = KdArti_New.KundenID AND KdArti.ArtikelID = KdArti_New.ArtikelID
WHERE LsKo.[Status] != N'W'
  AND LsKo.Datum >= N'2023-09-01';

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE LsKo SET VsaID = LsNew.VsaID_New
    FROM (
      SELECT DISTINCT #LsNew.LsKoID, #LsNew.VsaID_New
      FROM #LsNew
    ) AS LsNew
    WHERE LsNew.LsKoID = LsKo.ID;

    UPDATE LsPo SET AbteilID = #LsNew.AbteilID_New, KdArtiID = #LsNew.KdArtiID_New
    FROM #LsNew
    WHERE #LsNew.LsPoID = LsPo.ID;
  
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