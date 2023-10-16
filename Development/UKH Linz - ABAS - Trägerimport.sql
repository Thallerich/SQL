DECLARE @RentomatID int = 42;
DECLARE @VsaID int = (SELECT Vsa.ID FROM Vsa WHERE Vsa.RentomatID = @RentomatID);

DECLARE @ins TABLE (
  TraegerID int,
  TNr int
);

WITH ImportData AS (
  SELECT CAST(_ImportUKHLinz.MaNr AS varchar(8)) COLLATE Latin1_General_CS_AS AS Traeger,
    CAST(_ImportUKHLinz.Name AS nvarchar(40)) COLLATE Latin1_General_CS_AS AS Nachname,
    CAST(_ImportUKHLinz.Vorname AS nvarchar(20)) COLLATE Latin1_General_CS_AS AS Vorname,
    CAST(_ImportUKHLinz.Kartennummer AS nvarchar(25)) COLLATE Latin1_General_CS_AS AS RentomatKarte,
    CAST(CONCAT('40', _ImportUKHLinz.Artikelprofil) COLLATE Latin1_General_CS_AS AS varchar(8)) AS Funktionscode,
    CAST(IIF(LEFT(_ImportUKHLinz.ArtikelNr, 2) = N'20', SUBSTRING(_ImportUKHLinz.ArtikelNr, 3, 100), _ImportUKHLinz.ArtikelNr) AS nvarchar(15)) COLLATE Latin1_General_CS_AS AS ArtikelNr,
    _ImportUKHLinz.ArtikelNr COLLATE Latin1_General_CS_AS AS MatchArtikelNr,
    CAST(_ImportUKHLinz.Groesse AS nvarchar(12)) COLLATE Latin1_General_CS_AS AS Groesse,
    _ImportUKHLinz.TNr
  FROM Salesianer.dbo._ImportUKHLinz
)
UPDATE Salesianer.dbo._ImportUKHLinz SET RentoCodID = x.RentoCodID, ArtikelID = x.ArtikelID, ArtGroeID = x.ArtGroeID, KdArtiID = x.KdArtiID
FROM (
  SELECT ImportData.Traeger, ImportData.Nachname, ImportData.Vorname, ImportData.RentomatKarte, RentoCod.ID AS RentoCodID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID, ImportData.ArtikelNr, ImportData.Groesse, ImportData.TNr, ImportData.MatchArtikelNr
  FROM ImportData
  LEFT JOIN Artikel ON ImportData.ArtikelNr = Artikel.ArtikelNr
  LEFT JOIN ArtGroe ON ImportData.Groesse = ArtGroe.Groesse AND Artikel.ID = ArtGroe.ArtikelID
  LEFT JOIN RentoCod ON ImportData.Funktionscode = RentoCod.Funktionscode AND RentoCod.RentomatID = @RentomatID
  LEFT JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = (SELECT Vsa.KundenID FROM Vsa WHERE Vsa.ID = @VsaID) AND KdArti.Variante = N'-'
) x
WHERE x.TNr = _ImportUKHLinz.TNr AND x.MatchArtikelNr = _ImportUKHLinz.ArtikelNr COLLATE Latin1_General_CS_AS AND x.Groesse = _ImportUKHLinz.Groesse COLLATE Latin1_General_CS_AS;

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO Traeger (VsaID, Traeger, AbteilID, Vorname, Nachname, RentomatKarte, RentomatKredit, RentoCodID, RentoArtID, Indienst, IndienstDat)
    OUTPUT inserted.ID, inserted.Traeger
    INTO @ins (TraegerID, TNr)
    SELECT DISTINCT @VsaID, RIGHT(REPLICATE(N'0', 4) + CAST(_ImportUKHLinz.TNr AS nvarchar), 4) AS Traeger, VsaAbteil.AbteilID, _ImportUKHLinz.Vorname, _ImportUKHLinz.Name, _ImportUKHLinz.Kartennummer, CAST(6 AS int) AS RentomatKredit, _ImportUKHLinz.RentoCodID, CAST(2 AS int) AS RentoArtID, CAST(DATEPART(year, GETDATE()) AS nchar(4)) + N'/' + FORMAT(DATEPART(week, GETDATE()), N'00') AS Indienst, CAST(GETDATE() AS date) AS IndienstDat
    FROM Salesianer.dbo._ImportUKHLinz
    CROSS JOIN (
      SELECT Vsa.AbteilID
      FROM Vsa
      WHERE Vsa.ID = @VsaID
    ) VsaAbteil
    WHERE _ImportUKHLinz.RentoCodID IS NOT NULL;

    UPDATE Salesianer.dbo._ImportUKHLinz SET TraegerID = [@ins].TraegerID
    FROM @ins
    WHERE [@ins].TNr = _ImportUKHLinz.TNr;

    INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID)
    SELECT @VsaID, _ImportUKHLinz.TraegerID, _ImportUKHLinz.ArtGroeID, _ImportUKHLinz.KdArtiID
    FROM Salesianer.dbo._ImportUKHLinz
    WHERE _ImportUKHLinz.ArtGroeID IS NOT NULL AND _ImportUKHLinz.KdArtiID IS NOT NULL AND _ImportUKHLinz.TraegerID IS NOT NULL;

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