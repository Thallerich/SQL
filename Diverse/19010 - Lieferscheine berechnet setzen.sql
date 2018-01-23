USE Wozabal
GO

BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @LsKo TABLE (ID int);
		DECLARE @LsDatum date;

		SET @LsDatum = CAST(N'2017-07-31' AS date);    -- Lieferschein-Datum setzen; bis zu diesem Datum werden alle Lieferscheine auf berechnet gesetzt.

		INSERT INTO @LsKo
		SELECT DISTINCT LsKo.ID
		FROM LsKo
		JOIN Vsa ON LsKo.VsaID = Vsa.ID
		JOIN Kunden ON Vsa.KundenID = Kunden.ID AND Kunden.KdNr = 19010
		WHERE LsKo.Status < N'W'
		AND LsKo.Datum <= @LsDatum;

		UPDATE LsKo SET Status = N'W' WHERE ID IN (SELECT ID FROM @LsKo);

		UPDATE LsPo SET RechPoID = -4 WHERE RechPoID < 0 AND RechPoID <> -4 AND LsKoID IN (SELECT ID FROM @LsKo);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT N'' + ERROR_NUMBER() + ' ' + ERROR_MESSAGE();
END CATCH
GO