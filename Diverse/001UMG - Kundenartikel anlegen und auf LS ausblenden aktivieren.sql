DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Customer TABLE (
  KundenID int,
  KdBerID int,
  HasUMG bit
);

DECLARE @KdArtiInsert TABLE (
  KdArtiID int
);

INSERT INTO @Customer (KundenID, KdBerID, HasUMG)
SELECT Kunden.ID, KdBer.ID, HasUMG = ISNULL((SELECT 1 FROM KdArti WHERE KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = N'001UMG')), 0)
FROM Kunden
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN KdBer ON KdBer.KundenID = Kunden.ID
WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND [Zone].ZonenCode = N'SÜD'
  AND KdGf.KurzBez = N'MED'
  AND KdBer.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'BK')
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzHist
    WHERE EinzHist.KundenID = Kunden.ID
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.PoolFkt = 0
      AND EinzHist.EinzTeilID = (SELECT EinzTeil.ID FROM EinzTeil WHERE EinzTeil.CurrEinzHistID = EinzHist.ID)
  )
  AND EXISTS (
    SELECT Vsa.*
    FROM Vsa
    WHERE Vsa.KundenID = Kunden.ID
      AND EXISTS (
        SELECT StandBer.*
        FROM StBerSDC
        JOIN StandBer ON StBerSDC.StandBerID = StandBer.ID
        WHERE StandBer.StandKonID = Vsa.StandKonID
      )
      AND Vsa.[Status] = N'A'
  );


BEGIN TRY
  BEGIN TRANSACTION;
  
    /* TODO: Add Code here! */
    INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, Variante, LiefArtID, MaxWaschen, LSAusblenden, UserID_, AnlageUserID_)
    OUTPUT inserted.ID INTO @KdArtiInsert (KdArtiID)
    SELECT N'A', KundenID, (SELECT ID FROM Artikel WHERE ArtikelNr = N'001UMG'), KdBerID, N'-', 4, 85, 1, @UserID, @UserID
    FROM @Customer
    WHERE HasUMG = 0;

    INSERT INTO PrArchiv (KdArtiID, Datum, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @KdArtiInsert;

    UPDATE KdArti SET LSAusblenden = 1
    WHERE KundenID IN (SELECT KundenID FROM @Customer WHERE HasUMG = 1)
      AND ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = N'001UMG');
  
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

SELECT * FROM @Customer;