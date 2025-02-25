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
  (31208, 301, 10004549, 301),
  (31208, 302, 10004549, 302),
  (31208, 303, 10004549, 303),
  (31208, 315, 10004549, 315),
  (31209, 310, 10004548, 310),
  (31209, 311, 10004548, 311),
  (31209, 312, 10004548, 312),
  (31209, 315, 10004548, 315),
  (31209, 395, 10004548, 395);

UPDATE @MapTable SET VsaID_New = Vsa.ID, AbteilID_New = Vsa.AbteilID, KundenID_new = Kunden.ID
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = [@MapTable].KdNr_New
  AND Vsa.VsaNr = [@MapTable].VsaNr_New;

SELECT LsKo.ID AS LsKoID, [@MapTable].VsaID_New, LsPo.ID AS LsPoID, [@MapTable].AbteilID_New, KdArti_New.ID AS KdArtiID_New, ISNULL(Traeger_New.ID, LsKo.TraegerID) AS TraegerID_New
INTO #LsNew
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Traeger ON LsKo.TraegerID = Traeger.ID
JOIN @MapTable ON Kunden.KdNr = [@MapTable].KdNr_Old AND Vsa.VsaNr = [@MapTable].VsaNr_Old
JOIN KdArti AS KdArti_New ON [@MapTable].KundenID_new = KdArti_New.KundenID AND KdArti.ArtikelID = KdArti_New.ArtikelID
LEFT JOIN Traeger AS Traeger_New ON [@MapTable].VsaID_New = Traeger_New.VsaID AND Traeger.Traeger = Traeger_New.Traeger AND Traeger.Nachname = Traeger_New.Nachname AND Traeger.Vorname = Traeger_New.Vorname
WHERE LsKo.[Status] != N'W'
  AND LsKo.Datum >= N'2025-02-01';

INSERT INTO #LsNew (LsKoID, VsaID_New, LsPoID, AbteilID_New, KdArtiID_New, TraegerID_New)
SELECT LsKo.ID AS LsKoID, [@MapTable].VsaID_New, -1 AS LsPoID, -1 AS AbteilID_New, -1 AS KdArtiID_New, -1 AS TraegerID_New
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN @MapTable ON Kunden.KdNr = [@MapTable].KdNr_Old AND Vsa.VsaNr = [@MapTable].VsaNr_Old
WHERE LsKo.[Status] != N'W'
  AND LsKo.Datum >= N'2025-02-01'
  AND LsKo.LsKoArtID = (SELECT LsKoArt.ID FROM LsKoArt WHERE LsKoArt.Art = N'P')
  AND NOT EXISTS (
    SELECT 1
    FROM #LsNew
    WHERE #LsNew.LsKoID = LsKo.ID
  );

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE LsKo SET VsaID = LsNew.VsaID_New, TraegerID = LsNew.TraegerID_New, UserID_ = @userid
    FROM (
      SELECT DISTINCT #LsNew.LsKoID, #LsNew.VsaID_New, #LsNew.TraegerID_New
      FROM #LsNew
    ) AS LsNew
    WHERE LsNew.LsKoID = LsKo.ID;

    UPDATE LsPo SET AbteilID = #LsNew.AbteilID_New, KdArtiID = #LsNew.KdArtiID_New, UserID_ = @userid
    FROM #LsNew
    WHERE #LsNew.LsPoID = LsPo.ID
      AND #LsNew.LsPoID != -1
      AND #LsNew.AbteilID_New != -1
      AND #LsNew.KdArtiID_New != -1;
  
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