DECLARE @LsDelete TABLE (
  LsKoID int,
  LsPoID int,
  VsaLeasID int
);

INSERT INTO @LsDelete
SELECT LsPo.LsKoID, LsPo.ID, VsaLeas.ID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN VsaLeas ON LsPo.KdArtiID = VsaLeas.KdArtiID AND LsPo.AbteilID = VsaLeas.AbteilID AND LsKo.VsaID = VsaLeas.VsaID
WHERE LsKo.Datum > N'2019-02-03'
  AND LsPo.Anlage_ BETWEEN N'2019-01-22 14:53:00' AND N'2019-01-22 22:00:00'
  AND LsPo.AnlageUserID_ = 9374
  AND LsKo.Status = N'I';

BEGIN TRY
  BEGIN TRANSACTION
    DELETE FROM LsPo
    WHERE ID IN (
      SELECT LsPoID
      FROM @LsDelete
    );

    DELETE FROM LsKo
    WHERE ID IN (
        SELECT DISTINCT LsKoID
        FROM @LsDelete
      )
      AND NOT EXISTS (
        SELECT LsPo.*
        FROM LsPo
        WHERE LsPo.LsKoID = LsKo.ID
      );

    DELETE FROM LsKo
    WHERE LsKo.Datum > N'2019-02-03'
      AND NOT EXISTS (
        SELECT LsPo.*
        FROM LsPo
        WHERE LsPo.LsKoID = LsKo.ID
      );

    UPDATE VsaLeas SET VsaLeas.LieferscheinBis = N'2019-02-03'
    WHERE VsaLeas.ID IN (
        SELECT VsaLeasID
        FROM @LsDelete
      )
      AND VsaLeas.LieferscheinBis > N'2019-02-03';

    UPDATE Tage SET LeasLs = 0
    WHERE Tage.Datum > N'2019-02-03';
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  SELECT N'' + ERROR_NUMBER() + ' ' + ERROR_MESSAGE();
END CATCH