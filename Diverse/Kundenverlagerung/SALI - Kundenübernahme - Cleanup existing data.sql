DECLARE @KdNr int = 250827;

DECLARE @Cleanup TABLE (
  TeileID int,
  TraegerID int,
  TraeArtiID int
);

DECLARE @Error bit = 0;

INSERT INTO @Cleanup
SELECT Teile.ID AS TeileID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID
FROM Traeger
LEFT OUTER JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
LEFT OUTER JOIN Teile ON Teile.TraeArtiID = TraeArti.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'STHA');

BEGIN TRANSACTION;

  BEGIN TRY
    DELETE FROM Scans
    WHERE TeileID IN (
      SELECT TeileID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'Scans' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM Hinweis
    WHERE TeileID IN (
      SELECT TeileID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'Hinweis' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM Teile
    WHERE ID IN (
      SELECT TeileID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'Teile' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM TraeArch
    WHERE TraeArtiID IN (
      SELECT TraeArtiID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'TraeArch' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM TraeArti
    WHERE ID IN (
      SELECT TraeArtiID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'TraeArti' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM LeasDiff
    WHERE TraegerID IN (
      SELECT TraegerID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'LeasDiff' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM TeileLag
    WHERE TraegerID IN (
      SELECT TraegerID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'TeileLag' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    UPDATE TraeFach SET TraegerID = -1
    WHERE TraegerID IN (
      SELECT TraegerID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1;
    SELECT N'TraeFach' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

  BEGIN TRY
    DELETE FROM Traeger
    WHERE ID IN (
      SELECT TraegerID FROM @Cleanup
    );
  END TRY
  BEGIN CATCH
    SET @Error = 1
    SELECT N'Traeger' AS Aktion, ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;

IF @Error = 1
  ROLLBACK
ELSE
  COMMIT;