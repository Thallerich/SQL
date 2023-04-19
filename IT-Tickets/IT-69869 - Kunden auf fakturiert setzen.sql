DECLARE @LS TABLE (
  LsKoID int
);

BEGIN TRY
  BEGIN TRANSACTION;
    
    UPDATE LsPo SET RechPoID = -2
    OUTPUT inserted.LsKoID
    INTO @LS (LsKoID)
    WHERE LsPo.ID IN (
      SELECT LsPo.ID
      FROM LsPo
      JOIN LsKo ON LsPo.LsKoID = LsKo.ID
      JOIN Vsa ON LsKo.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      WHERE LsKo.Datum < N'2023-04-01'
        AND Kunden.KdNr IN (2300, 6060)
        AND LsPo.RechPoID = -1
    );

    UPDATE LsKo SET [Status] = N'W'
    WHERE LsKo.ID IN (SELECT LsKoID FROM @LS)
      AND LsKo.[Status] < N'W';

    UPDATE AbtKdArW SET RechPoID = -2
    WHERE AbtKdArW.ID IN (
      SELECT AbtKdArW.ID
      FROM AbtKdArW
      JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
      JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
      JOIN Kunden ON Abteil.KundenID = Kunden.ID
      WHERE Kunden.KdNr IN (2300, 6060)
        AND Wochen.Monat1 < N'2023-04'
        AND AbtKdArW.RechPoID = -1
    );

    UPDATE Kunden SET MonatAbgeschl = N'2023-03'
    WHERE Kunden.KdNr IN (2300, 6060);

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