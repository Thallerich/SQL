DECLARE @kdnr int = 10002702;
DECLARE @ersatz nchar(15) = N'110620010020';
DECLARE @artikel nchar(15) = N'110620662001';
DECLARE @clearoldersatz bit = 0;

DECLARE @ersatzID int, @artikelID int, @kundenID int;
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @ErsatzTeil TABLE (
  EinzTeilID int PRIMARY KEY
);

SELECT @kundenID = Kunden.ID, @artikelID = KdArti.ID, @ersatzID = KdArtiErsatz.ID
FROM Kunden
JOIN KdArti ON Kunden.ID = KdArti.KundenID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti AS KdArtiErsatz ON Kunden.ID = KdArtiErsatz.KundenID
JOIN Artikel AS ArtikelErsatz ON KdArtiErsatz.ArtikelID = ArtikelErsatz.ID
WHERE Kunden.KdNr = @kdnr
  AND Artikel.ArtikelNr = @artikel
  AND ArtikelErsatz.ArtikelNr = @ersatz
  AND KdArti.Variante = N'-'
  AND KdArtiErsatz.Variante = N'-';

INSERT INTO @ErsatzTeil (EinzTeilID)
SELECT EinzTeil.ID
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @kdnr
  AND Artikel.ArtikelNr IN (@ersatz, @artikel)
  AND EinzTeil.Status != N'Z'
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154, 173);

BEGIN TRY
  
  BEGIN TRANSACTION;
    
    IF @clearoldersatz = 1
      UPDATE KdArti SET ErsatzFuerKdArtiID = -1, UserID_ = @userid
      WHERE ErsatzFuerKdArtiID = @ersatzID;

    UPDATE EinzTeil SET LastErsatzFuerKdArtiID = -1, LastErsatzArtGroeID = -1, UserID_ = @userid
    WHERE ID IN (SELECT EinzTeilID FROM @ErsatzTeil)
      AND (LastErsatzFuerKdArtiID > 0 OR LastErsatzArtGroeID > 0);

  COMMIT TRANSACTION;

END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();

  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
 
  RAISERROR(@Message, @Severity, @State);
END CATCH;