DECLARE @VsaTourReactivate TABLE (
  VsaTourID int PRIMARY KEY CLUSTERED
);

INSERT INTO @VsaTourReactivate (VsaTourID)
SELECT VsaTour.ID
FROM VsaTour
JOIN Touren ON VsaTour.TourenID = Touren.ID
WHERE VsaTour.VsaID IN (
    SELECT Vsa.ID
    FROM Vsa
    WHERE Vsa.KundenID = (
      SELECT Kunden.ID
      FROM Kunden
      WHERE Kunden.KdNr = 20150
    )
  )
  AND VsaTour.BisDatum >= N'2023-12-20'
  AND VsaTour.BisDatum != N'2099-12-31'
  AND VsaTour.KdBerID IN (
    SELECT KdBer.ID
    FROM KdBer
    WHERE KdBer.KundenID = (
        SELECT Kunden.ID
        FROM Kunden
        WHERE Kunden.KdNr = 20150
      )
      AND KdBer.BereichID IN (
        SELECT Bereich.ID
        FROM Bereich
        WHERE Bereich.Bereich IN (N'FW', N'LW')
      )
  )
  AND NOT EXISTS (
    SELECT vt.*
    FROM VsaTour AS vt
    JOIN Touren AS t ON vt.TourenID = t.ID
    WHERE vt.VsaID = VsaTour.VsaID
      AND t.Wochentag = Touren.Wochentag
      AND vt.VonDatum > VsaTour.BisDatum
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE VsaTour SET BisDatum = N'2099-12-31'
    WHERE ID IN (
      SELECT VsaTourID
      FROM @VsaTourReactivate
    );
  
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