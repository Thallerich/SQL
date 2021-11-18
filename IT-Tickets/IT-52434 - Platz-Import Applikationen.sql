BEGIN TRANSACTION;

  DECLARE @KdArPlatzUpdate TABLE (
    KdArApplID int,
    PlatzID int
  );

  DECLARE @TraePlatzUpdate TABLE (
    TraeApplID int,
    PlatzID int
  );

  WITH PlatzImport AS (
    SELECT KdNr,
      ArtikelNr COLLATE Latin1_General_CS_AS AS ArtikelNr,
      Art = CASE NsEmbl
        WHEN N'E' THEN 3
        WHEN N'N' THEN 2
      END,
      Platz.ID AS PlatzID
    FROM Salesianer.dbo.__PlatzImport
    JOIN Platz ON __PlatzImport.PlatzNeu COLLATE Latin1_General_CS_AS = Platz.Code
  )
  UPDATE KdArAppl SET PlatzID = PlatzImport.PlatzID
  OUTPUT inserted.ID, inserted.PlatzID
  INTO @KdArPlatzUpdate (KdArApplID, PlatzID)
  --SELECT KdArAppl.ID, KdArAppl.PlatzID, PlatzImport.PlatzID AS PlatzIDNeu
  FROM KdArAppl
  JOIN KdArti ON KdArAppl.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN KdArti AS Applikation ON KdArAppl.ApplKdArtiID = Applikation.ID
  JOIN Artikel AS ApplArti ON Applikation.ArtikelID = ApplArti.ID
  JOIN PlatzImport ON Kunden.KdNr = PlatzImport.KdNr AND Artikel.ArtikelNr = PlatzImport.ArtikelNr AND ApplArti.ArtiTypeID = PlatzImport.Art;

  UPDATE TraeAppl SET PlatzID = PlatzUpdate.PlatzID
  OUTPUT inserted.ID, inserted.PlatzID
  INTO @TraePlatzUpdate (TraeApplID, PlatzID)
  FROM TraeAppl
  JOIN @KdArPlatzUpdate AS PlatzUpdate ON PlatzUpdate.KdArApplID = TraeAppl.KdArApplID;

  UPDATE TeilAppl SET PlatzID = PlatzUpdate.PlatzID
  FROM TeilAppl
  JOIN @TraePlatzUpdate AS PlatzUpdate ON PlatzUpdate.TraeApplID = TeilAppl.TraeApplID;

  UPDATE RepQueue SET Priority = 90000 + Priority
  WHERE ApplicationID = N'AdvanTex.exe';

--COMMIT
--ROLLBACK