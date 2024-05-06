DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Customer TABLE (
  CustomerID int PRIMARY KEY CLUSTERED
);

INSERT INTO @Customer (CustomerID)
SELECT Kunden.ID AS KundenID
FROM Kunden
WHERE Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'FA14')
  AND Kunden.KdGfID = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'JOB')
  AND Kunden.ZoneID = (SELECT [Zone].ID FROM [Zone] WHERE [Zone].ZonenCode = N'OST')
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Kunden.KdNr NOT IN (233042, 10005132, 233126, 10005482, 200785, 10001300, 10001298, 10000013, 10004371, 10006287, 10006352, 10006489, 10006708, 10006926) /* lt. Excel-Liste und Cigdem nicht ändern */
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzHist.KundenID = Kunden.ID
      AND EinzTeil.AltenheimModus = 0
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Kunden SET AustauschRueckfr = N'D', AustauschBisWocheErlaubt = 104, FakAustausch = 1
    WHERE Kunden.ID IN (SELECT CustomerID FROM @Customer);

    INSERT INTO KdTauFak (KundenID, MaxAnzWochen, Typ, AnlageUserID_, UserID_)
    SELECT CustomerID AS KundenID, CAST(104 AS int) AS MaxWochen, CAST(0 AS int) AS Typ, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @Customer
    WHERE NOT EXISTS (
      SELECT KdTauFak.*
      FROM KdTauFak
      WHERE KdTauFak.KundenID = [@Customer].CustomerID
        AND KdTauFak.WegGrundID = -1
        AND KdTauFak.KdArtiID = -1
        AND KdTauFak.Typ = 0
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

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-82258                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Customer TABLE (
  CustomerID int PRIMARY KEY CLUSTERED
);

INSERT INTO @Customer (CustomerID)
SELECT Kunden.ID AS KundenID
FROM Kunden
WHERE Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'FA14')
  AND Kunden.KdGfID = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'JOB')
  AND Kunden.ZoneID = (SELECT [Zone].ID FROM [Zone] WHERE [Zone].ZonenCode = N'OST')
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Kunden.KdNr NOT IN (233042, 10005132, 233126, 10005482, 200785, 10001300, 10001298, 10000013, 10004371, 10006287, 10006352, 10006489, 10006708, 10006926) /* lt. Excel-Liste und Cigdem nicht ändern */
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzHist.KundenID = Kunden.ID
      AND EinzTeil.AltenheimModus = 0
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Kunden SET FakSchrott = 1
    WHERE Kunden.ID IN (SELECT CustomerID FROM @Customer);

    INSERT INTO KdTauFak (KundenID, MaxAnzWochen, Typ, AnlageUserID_, UserID_)
    SELECT CustomerID AS KundenID, CAST(104 AS int) AS MaxWochen, CAST(1 As int) AS Typ, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @Customer
    WHERE NOT EXISTS (
      SELECT KdTauFak.*
      FROM KdTauFak
      WHERE KdTauFak.KundenID = [@Customer].CustomerID
        AND KdTauFak.WegGrundID = -1
        AND KdTauFak.KdArtiID = -1
        AND KdTauFak.Typ = 1
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

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden
WHERE Kunden.ID IN (SELECT CustomerID FROM @Customer);

GO