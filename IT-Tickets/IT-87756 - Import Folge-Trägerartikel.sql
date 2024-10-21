SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
DROP TABLE IF EXISTS #FolgeImport;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   ++ Table-Structure for import-table (_IT87756):                                                                               ++
   ++   KdNr int                                                                                                                ++
   ++   VsaNr int                                                                                                               ++
   ++   Traeger nchar(8)                                                                                                        ++
   ++   ArtikelNr nvarchar(15)                                                                                                  ++
   ++   Variante nvarchar(2)                                                                                                    ++
   ++   Groesse nvarchar(12)                                                                                                    ++
   ++   Folge_ArtikelNr nvarchar(15)                                                                                            ++
   ++   Folge_Groesse nvarchar(12)                                                                                              ++
   ++   Folge_Variante nvarchar(2)                                                                                              ++
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @ispadded bit = 1; /* set to 1 if Traeger.Traeger contains leading zeroes and import-list does not, otherwise set to zero */
DECLARE @forcefolge bit = 0; /* set to 1 if the flag "Zwingend" should be set to force usage of the "Folge-Artikel" even if stock for the old article is available */

DECLARE @msg nvarchar(max);

IF @ispadded = 1
BEGIN
  UPDATE _IT87756 SET Traeger = RIGHT(N'0000' + RTRIM(Traeger), 4)
  WHERE RTRIM(Traeger) NOT LIKE N'____';

  SET @msg = FORMAT(@@ROWCOUNT, N'N0') + N' Träger-Nummern mit Nullen auf 4 Stellen aufgefüllt!';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;
END;

DELETE FROM _IT87756 WHERE Folge_ArtikelNr IS NULL OR Folge_Groesse IS NULL OR Folge_Variante IS NULL;
SET @msg = FORMAT(@@ROWCOUNT, N'N0') + N' ungültige Einträge aus Import-Tabelle gelöscht. (keine Folge-ArtikelNr, Folge-Variante, Folge-Größe)';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

SELECT Traeger.ID AS TraegerID, KdArti.ID AS KdArtiID, ArtGroe.ID AS ArtGroeID, FolgeKdArti.ID AS FolgeKdArtiID, FolgeArtGroe.ID AS FolgeArtGroeID, CAST(NULL AS int) AS FolgeTraeArtiID
INTO #FolgeImport
FROM _IT87756
JOIN Traeger ON _IT87756.Traeger COLLATE Latin1_General_CS_AS = Traeger.Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID AND _IT87756.VsaNr = Vsa.VsaNr
JOIN Kunden ON Vsa.KundenID = Kunden.ID AND _IT87756.KdNr = Kunden.KdNr
JOIN KdArti ON KdArti.KundenID = Kunden.ID AND _IT87756.Variante COLLATE Latin1_General_CS_AS = KdArti.Variante
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID AND _IT87756.ArtikelNr COLLATE Latin1_General_CS_AS = Artikel.ArtikelNr
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND _IT87756.Groesse COLLATE Latin1_General_CS_AS = ArtGroe.Groesse
JOIN KdArti AS FolgeKdArti ON FolgeKdArti.KundenID = Kunden.ID AND _IT87756.Folge_Variante COLLATE Latin1_General_CS_AS = FolgeKdArti.Variante
JOIN Artikel AS FolgeArtikel ON FolgeKdArti.ArtikelID = FolgeArtikel.ID AND _IT87756.Folge_ArtikelNr COLLATE Latin1_General_CS_AS = FolgeArtikel.ArtikelNr
JOIN ArtGroe AS FolgeArtGroe ON FolgeArtGroe.ArtikelID = FolgeArtikel.ID AND _IT87756.Folge_Groesse COLLATE Latin1_General_CS_AS = FolgeArtGroe.Groesse;

UPDATE #FolgeImport SET FolgeTraeArtiID = TraeArti.ID
FROM TraeArti
WHERE TraeArti.TraegerID = #FolgeImport.TraegerID
  AND TraeArti.KdArtiID = #FolgeImport.FolgeKdArtiID
  AND TraeArti.ArtGroeID = #FolgeImport.FolgeArtGroeID;

SET @msg = FORMAT(@@ROWCOUNT, N'N0') + N' Trägerartikel für Folge-Trägerartikel-Update ermittelt';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE TraeArti SET FolgeTraeArtiID = #FolgeImport.FolgeTraeArtiID, FolgeArtZwingend = @forcefolge
    FROM #FolgeImport
    WHERE #FolgeImport.TraegerID = TraeArti.TraegerID
      AND #FolgeImport.KdArtiID = TraeArti.KdArtiID
      AND #FolgeImport.ArtGroeID = TraeArti.ArtGroeID
      AND TraeArti.FolgeTraeArtiID = -1;

    SET @msg = FORMAT(@@ROWCOUNT, N'N0') + N' Folge-Trägerartikel wurden im AdvanTex zugeordnet!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
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

DROP TABLE IF EXISTS #FolgeImport;
GO