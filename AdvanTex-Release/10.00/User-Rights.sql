SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DECLARE @Testmodus BIT = 0;-- Set to 1 to test query. All changes done by the query will be rollbacked
/* ------------------------------------------------------------------------------------------------------- */
DECLARE @TransactionName VARCHAR(20);

SELECT @TransactionName = 'T1';

DECLARE @Rowcnt INT;

BEGIN
    IF @Testmodus = 1
        PRINT 'Starting Script in Development'
    ELSE
        PRINT 'Starting Script in Production'
END

BEGIN TRY
    BEGIN TRANSACTION @TransactionName;

    PRINT 'Executing Query...'

    /* ################################################################################################################################# */
    /* ################################################################################################################################# */
    -- Zuweisen der neuen Rechte anhand der Zuweisung in Tabelle / Excelliste 
    MERGE INTO MODACT
    USING (
        SELECT FormactID
            , RightsID
            , RightsNeu.ID AS RightsNeuID
        FROM RIGHTS
        JOIN MODACT
            ON MODACT.RightsID = Rights.ID
        JOIN FORMACT
            ON MODACT.FormActID = FormAct.ID
        JOIN /*[saladvssqlc1a1.salres.com].[Salesianer].[dbo].*/[__rechterelease10] RechteNeu
            ON (
                    Formact.Formclass = RechteNeu.Formclass COLLATE Latin1_General_CS_AS
                    AND Formact.Actionname = RechteNeu.Actionname COLLATE Latin1_General_CS_AS
                    )
        JOIN Rights RightsNeu
            ON RechteNeu.NeuesRechtBez COLLATE Latin1_General_CS_AS = RightsNeu.RightsBez
        WHERE rights.id = 901149
        ) AS source(FormactID, RightsID, RightsNeuID)
        ON source.formactid = modact.formactID
            AND modact.rightsID = RightsNeuID
    WHEN NOT MATCHED
        THEN
            INSERT (
                FormactID
                , RightsID
                )
            VALUES (
                Source.FormactID
                , RightsNeuID
                );

    SET @Rowcnt = @@ROWCOUNT

    -- Zuweisen aller Rechte für IT
    DECLARE @ITRightID AS INTEGER

    SET @ITRightID = (
            SELECT TOP 1 ID
            FROM rights
            WHERE RightsBez = '#_IT(Admin)'
            )

    MERGE INTO MODACT
    USING (
        SELECT FormactID
            , RightsID
        FROM RIGHTS
        JOIN MODACT
            ON MODACT.RightsID = Rights.ID
        JOIN FORMACT
            ON MODACT.FormActID = FormAct.ID
        WHERE rights.id = 901149
        ) AS source(FormactID, RightsID)
        ON source.formactid = modact.formactID
            AND modact.rightsID = @ITRightID
    WHEN NOT MATCHED
        THEN
            INSERT (
                FormactID
                , RightsID
                )
            VALUES (
                Source.FormactID
                , @ITRightID
                );

    SET @Rowcnt = @Rowcnt + @@ROWCOUNT

    -- CleanUp // just to be safe falls eine action von vorangegangenden Skripten nicht erfasst wurde wird es spätestens hier gesperrt und dadurch f. IT Sichtbar gemacht
    INSERT INTO MODACT (
        FormactID
        , RightsID
        , SichtKatID
        )
    SELECT Modact.FormactID
        , 901095
        , - 1
    FROM MODACT
    WHERE EXISTS (
            SELECT *
            FROM MODACT m
            WHERE RIGHTSID = 901149
                AND m.formactid = modact.formactid
            )
        AND NOT EXISTS (
            SELECT *
            FROM MODACT m
            WHERE RIGHTSID <> 901149
                AND m.formactid = modact.formactid
            )

    SET @Rowcnt = @Rowcnt + @@ROWCOUNT

    --Cleanup - Löschen aller Zuweisungen bei Recht #_Neuefunktionen
    DELETE
    FROM modact
    WHERE rightsid = 901149

    SET @Rowcnt = @Rowcnt + @@ROWCOUNT

    /* ################################################################################################################################# */
    /* ################################################################################################################################# */
    IF @Rowcnt = 0
        PRINT 'Warning: No rows were updated';
    ELSE
        PRINT CAST(@Rowcnt AS VARCHAR) + ' rows in total affected'

    IF @Testmodus = 1
    BEGIN
        PRINT 'Rollbacking changes...'

        ROLLBACK TRANSACTION @TransactionName;

        PRINT 'Rollback complete';
    END
    ELSE
    BEGIN
        PRINT 'Commiting changes...'

        COMMIT TRANSACTION @TransactionName;

        PRINT 'Commit complete'
    END
END TRY

BEGIN CATCH
    DECLARE @Message VARCHAR(MAX) = ERROR_MESSAGE();
    DECLARE @Severity INT = ERROR_SEVERITY();
    DECLARE @State SMALLINT = ERROR_STATE();

    IF XACT_STATE() != 0
        ROLLBACK TRANSACTION;

    RAISERROR (
            @Message
            , @Severity
            , @State
            )
    WITH NOWAIT;
END CATCH;


GO

DROP TABLE __rechterelease10;

GO