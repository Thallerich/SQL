/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Parameter                                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @KdNr int = 0; /* Kundennummer hier eintragen! */
DECLARE @Traeger bit = 1; /* Träger anonymisieren? 1 = Ja / 0 = Nein */
DECLARE @Ansprechpartner bit = 0; /* Ansprechpartner anonymisieren? 1 = Ja / 0 = Nein */
DECLARE @Webuser bit = 0; /* Web-User anonymisieren? 1 = Ja / 0 = Nein */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Code - NICHT ÄNDERN!                                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @sqltext nvarchar(max);
DECLARE @message nvarchar(max);
DECLARE @rowcount int;

SET NOCOUNT ON;

IF @Traeger = 1
BEGIN

  SET @sqltext = N'
    UPDATE History SET History.Memo = REPLACE(REPLACE(History.Memo, ISNULL(Traeger.Vorname, N''''), N''**********''), ISNULL(Traeger.Nachname, N''''), N''**********'')
    FROM Traeger, Vsa, Kunden
    WHERE History.TableID = Traeger.ID
      AND History.TableName = N''TRAEGER''
      AND Traeger.VsaID = Vsa.ID
      AND Vsa.KundenID = Kunden.ID
      AND Kunden.KdNr = @KdNr
      AND NOT EXISTS (
        SELECT Teile.*
        FROM Teile
        WHERE Teile.TraegerID = Traeger.ID
          AND ((Teile.Status = N''W'' AND Teile.Einzug IS NULL) OR Teile.Ausdienst IS NULL)
      )
      AND NOT EXISTS (
        SELECT BPo.*
        FROM BPo, BKo
        WHERE BPo.TraegerID = Traeger.ID
          AND BPo.BKoID = BKo.ID
          AND BKo.BKoArtID = 15
          AND BKo.Status < N''M''
      );

    SELECT @rowcount = @@ROWCOUNT;
  ';

  EXEC sp_executesql @sqltext, N'@KdNr int, @rowcount int OUTPUT', @KdNr, @rowcount OUTPUT;

  SET @message = N'HISTORY: ' + CAST(@rowcount AS nvarchar) + ' Datensätze anonymisiert!';
  PRINT @message;
  

  SET @sqltext = N'
    UPDATE BPo SET
      Zeile1 = LEFT(REPLACE(REPLACE(REPLACE(BPo.Zeile1, ISNULL(Traeger.Vorname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), ISNULL(Traeger.Nachname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Vorname, N''''))), N''**********''), LEFT(ISNULL(Traeger.Vorname, N''''), 1) + N''. '' + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), 40),
      Zeile2 = LEFT(REPLACE(REPLACE(REPLACE(BPo.Zeile2, ISNULL(Traeger.Vorname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), ISNULL(Traeger.Nachname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Vorname, N''''))), N''**********''), LEFT(ISNULL(Traeger.Vorname, N''''), 1) + N''. '' + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), 40),
      Zeile3 = LEFT(REPLACE(REPLACE(REPLACE(BPo.Zeile3, ISNULL(Traeger.Vorname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), ISNULL(Traeger.Nachname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Vorname, N''''))), N''**********''), LEFT(ISNULL(Traeger.Vorname, N''''), 1) + N''. '' + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), 40),
      Zeile4 = LEFT(REPLACE(REPLACE(REPLACE(BPo.Zeile4, ISNULL(Traeger.Vorname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), ISNULL(Traeger.Nachname + N'' '', N'''') + LTRIM(RTRIM(ISNULL(Traeger.Vorname, N''''))), N''**********''), LEFT(ISNULL(Traeger.Vorname, N''''), 1) + N''. '' + LTRIM(RTRIM(ISNULL(Traeger.Nachname, N''''))), N''**********''), 40)
    FROM BPo, BKo, Traeger, Vsa, Kunden
    WHERE BPo.TraegerID = Traeger.ID
      AND Traeger.VsaID = Vsa.ID
      AND Vsa.KundenID = Kunden.ID
      AND BKo.ID = BPo.BKoID
      AND BKo.BKoArtID IN (15, 11)
      AND Kunden.KdNr = @KdNr
      AND NOT EXISTS (
        SELECT Teile.*
        FROM Teile
        WHERE Teile.TraegerID = Traeger.ID
          AND ((Teile.Status = N''W'' AND Teile.Einzug IS NULL) OR Teile.Ausdienst IS NULL)
      )
      AND NOT EXISTS (
        SELECT BPo.*
        FROM BPo, BKo
        WHERE BPo.TraegerID = Traeger.ID
          AND BPo.BKoID = BKo.ID
          AND BKo.BKoArtID = 15
          AND BKo.Status < N''M''
      );

    SELECT @rowcount = @@ROWCOUNT;
  ';

  EXEC sp_executesql @sqltext, N'@KdNr int, @rowcount int OUTPUT', @KdNr, @rowcount OUTPUT;

  SET @message = N'BESTELLUNGEN: ' + CAST(@rowcount AS nvarchar) + ' Datensätze anonymisiert!';
  PRINT @message;

  SET @sqltext = N'
    UPDATE Traeger SET Vorname = N''**********'', Nachname = N''**********'', Titel = NULL, Namenschild1 = NULL, Namenschild2 = NULL, Namenschild3 = NULL, Namenschild4 = NULL, Geschlecht = N''?''
    FROM Vsa, Kunden
    WHERE Traeger.VsaID = Vsa.ID
      AND Vsa.KundenID = Kunden.ID
      AND Kunden.KdNr = @KdNr
      AND NOT EXISTS (
        SELECT Teile.*
        FROM Teile
        WHERE Teile.TraegerID = Traeger.ID
          AND ((Teile.Status = N''W'' AND Teile.Einzug IS NULL) OR Teile.Ausdienst IS NULL)
      )
      AND NOT EXISTS (
        SELECT BPo.*
        FROM BPo, BKo
        WHERE BPo.TraegerID = Traeger.ID
          AND BPo.BKoID = BKo.ID
          AND BKo.BKoArtID = 15
          AND BKo.Status < N''M''
      );

    SELECT @rowcount = @@ROWCOUNT;
  ';

  EXEC sp_executesql @sqltext, N'@KdNr int, @rowcount int OUTPUT', @KdNr, @rowcount OUTPUT;

  SET @message = N'TRÄGER / BEWOHNER: ' + CAST(@rowcount AS nvarchar) + ' Datensätze anonymisiert!';
  PRINT @message;

END;

IF @Ansprechpartner = 1
BEGIN
  SET @sqltext = N'
    UPDATE Sachbear SET AnzeigeName = N''**********'', Vorname = N''**********'', [Name] = N''**********'', Anrede = NULL, Titel = NULL, Abteilung = NULL, [Position] = NULL, Telefon = NULL, TelefonNorm = NULL, Telefax = NULL, TelefaxNorm = NULL, Mobil = NULL, MobilNorm = NULL, eMail = NULL, Bemerk = NULL, SerienAnrede = NULL, Geburtstag = NULL
    FROM Kunden
    WHERE Sachbear.TableID = Kunden.ID
      AND Sachbear.TableName = N''KUNDEN''
      AND Kunden.KdNr = @KdNr;

    SELECT @rowcount = @@ROWCOUNT;
  ';

  EXEC sp_executesql @sqltext, N'@KdNr int, @rowcount int OUTPUT', @KdNr, @rowcount OUTPUT;

  SET @message = N'KUNDEN-ANSPRECHPARTNER! ' + CAST(@rowcount AS nvarchar) + ' Datensätze anonymisiert!';
  PRINT @message;

  SET @sqltext = N'
    UPDATE Sachbear SET AnzeigeName = N''**********'', Vorname = N''**********'', [Name] = N''**********'', Anrede = NULL, Titel = NULL, Abteilung = NULL, [Position] = NULL, Telefon = NULL, TelefonNorm = NULL, Telefax = NULL, TelefaxNorm = NULL, Mobil = NULL, MobilNorm = NULL, eMail = NULL, Bemerk = NULL, SerienAnrede = NULL, Geburtstag = NULL
    FROM Vsa, Kunden
    WHERE Sachbear.TableID = Vsa.ID
      AND Sachbear.TableName = N''VSA''
      AND Vsa.KundenID = Kunden.ID
      AND Kunden.KdNr = @KdNr;

    SELECT @rowcount = @@ROWCOUNT;
  ';

  EXEC sp_executesql @sqltext, N'@KdNr int, @rowcount int OUTPUT', @KdNr, @rowcount OUTPUT;

  SET @message = N'VSA-ANSPRECHPARTNER! ' + CAST(@rowcount AS nvarchar) + ' Datensätze anonymisiert!';
  PRINT @message;

END;

IF @Webuser = 1
BEGIN
  
  SET @sqltext = N'
    UPDATE WebUser SET Username = CAST(WebUser.ID AS nvarchar(80)), UserPassword = NULL, Password = NULL, Status = N''I'', FullName = N''**********'', Geschlecht = N''?'', CCeMail = NULL, eMail = NULL, BCCeMail = NULL, ParentWebUserID = -1, SerienAnrede = NULL, UserPasswordSalt = NULL
    FROM Kunden
    WHERE WebUser.KundenID = Kunden.ID
      AND Kunden.KdNr = @KdNr;

    SELECT @rowcount = @@ROWCOUNT;
  ';

  EXEC sp_executesql @sqltext, N'@KdNr int, @rowcount int OUTPUT', @KdNr, @rowcount OUTPUT;

  SET @message = N'WEB-USER: ' + CAST(@rowcount AS nvarchar) + ' Datensätze anonymisiert!';
  PRINT @message;

END;