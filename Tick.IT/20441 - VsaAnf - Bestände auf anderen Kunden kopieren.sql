USE Wozabal
GO

DECLARE @KdNrNeu integer;
DECLARE @KdNrAlt integer;

SET @KdNrNeu = 60660;
SET @KdNrAlt = 60960;

-- Vertragsbestand / Ausstehende Reduzierung kopieren
BEGIN TRANSACTION CopyVB;
  BEGIN TRY
    UPDATE VsaAnf SET VsaAnf.Bestand = x.Bestand, VsaAnf.AusstehendeReduz = x.AusstehendeReduz
    FROM (
      SELECT VsaAnfKdNeu.ID, VsaAnfKdAlt.Bestand, VsaAnfKdAlt.AusstehendeReduz
      FROM VsaAnf AS VsaAnfKdNeu, VsaAnf AS VsaAnfKdAlt, Vsa AS VsaKdNeu, Vsa AS VsaKdAlt, Kunden AS KdNeu, Kunden AS KdAlt, KdArti AS KdArtiKdNeu, KdArti AS KdArtiKdAlt, Artikel
      WHERE VsaAnfKdNeu.KdArtiID = KdArtiKdNeu.ID
        AND KdArtiKdNeu.ArtikelID = Artikel.ID
        AND VsaAnfKdNeu.VsaID = VsaKdNeu.ID
        AND VsaKdNeu.KundenID = KdNeu.ID
        AND VsaAnfKdAlt.VsaID = VsaKdAlt.ID
        AND VsaKdAlt.KundenID = KdAlt.ID
        AND VsaAnfKdAlt.KdArtiID = KdArtiKdAlt.ID
        AND KdArtiKdAlt.ArtikelID = Artikel.ID
        AND VsaKdNeu.VsaNr = VsaKdAlt.VsaNr
        AND VsaAnfKdNeu.ArtGroeID = VsaAnfKdAlt.ArtGroeID
        AND KdNeu.KdNr = @KdNrNeu
        AND KdAlt.KdNr = @KdNrAlt
    ) AS x
    WHERE x.ID = VsaAnf.ID;

    UPDATE OPTeile SET OPTeile.VsaID = x.VsaID
    FROM (
      SELECT OPTeile.ID, VsaKdNeu.ID AS VsaID
      FROM OPTeile, Vsa AS VsaKdAlt, Kunden AS KdAlt, Vsa AS VsaKdNeu, Kunden AS KdNeu
      WHERE OPTeile.VsaID = VsaKdAlt.ID
        AND VsaKdAlt.KundenID = KdAlt.ID
        AND VsaKdNeu.KundenID = KdNeu.ID
        AND VsaKdAlt.VsaNr = VsaKdNeu.VsaNr
        AND KdNeu.KdNr = @KdNrNeu
        AND KdAlt.KdNr = @KdNrAlt
    ) AS x
    WHERE x.ID = OPTeile.ID;
  END TRY
  BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage; 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
  END CATCH;
IF @@TRANCOUNT> 0 COMMIT TRANSACTION;

-- Ist-Bestände neu errechnen (beim neuen Kunden)
BEGIN TRANSACTION RecalcIstbestand;
  BEGIN TRY
    DROP TABLE IF EXISTS #OpTeilMeng;

    SELECT VsaAnf.ID AS VsaAnfID, Kunden.KdNr, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez ArtikelBez, IIF(Daten.LastErsatzFuerKdArtiID > 0, Daten.LastErsatzFuerKdArtiID, VsaAnf.KdArtiID) KdArtiID, Vsa.ID VsaID, VsaAnf.Bestand SollBestand, VsaAnf.BestandIst VsaAnfBestandIst, 0 AnzLsUngedruckt, COUNT(Daten.ID) AS BestandIst, SUM(IIF(Daten.LastErsatzFuerKdArtiID <> -1, 1, 0)) VomIstBestandErsatz, SUM(IIF(Daten.LastErsatzFuerKdArtiID <> -1, 0, 1)) IstBestandOrig, MIN(Daten.ID) OpTeileID
    INTO #OpTeilMeng 
    FROM (
      SELECT OpTeile.ID, OpTeile.VsaID, OpTeile.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass 
      FROM OpTeile, KdArti, Vsa, Kunden
      WHERE OpTeile.LastErsatzFuerKdArtiID > -1
        AND OpTeile.LastErsatzFuerKdArtiID = KdArti.ID
        AND OpTeile.Status = N'R'
        AND OpTeile.VsaID > 0
        AND OpTeile.VsaID = Vsa.ID 
        AND Vsa.KundenID = KdArti.KundenID
        AND Vsa.KundenID = Kunden.ID
        AND Kunden.KdNr = @KdNrNeu
      UNION ALL
      SELECT OpTeile.ID, OpTeile.VsaID, OpTeile.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass
      FROM OpTeile, KdArti, Vsa, Kunden
      WHERE OpTeile.LastErsatzFuerKdArtiID = -1
        AND OpTeile.Status = N'R'
        AND OpTeile.VsaID > 0
        AND OpTeile.VsaID = Vsa.ID 
        AND Vsa.KundenID = KdArti.KundenID
        AND OpTeile.ArtikelID = KdArti.ArtikelID
        AND Vsa.KundenID = Kunden.ID
        AND Kunden.KdNr = @KdNrNeu
    ) AS Daten, Vsa, KdBer, VsaAnf, Kunden, Artikel
    WHERE Vsa.ID = Daten.VsaID
      AND Vsa.KundenID = KdBer.KundenID
      AND Kunden.ID = Vsa.KundenID
      AND Daten.KdBerID = KdBer.ID
      AND Artikel.ID = Daten.ArtikelID
      AND ((KdBer.IstBestandAnpass = 1) OR (Daten.IstBestandAnpass = 1))
      AND VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.KdArtiID = Daten.KdArtiID
      AND VsaAnf.ArtGroeID = -1
      AND Kunden.KdNr = @KdNrNeu
    GROUP BY VsaAnf.ID, Kunden.KdNr, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, IIF(Daten.LastErsatzFuerKdArtiID > 0, Daten.LastErsatzFuerKdArtiID, VsaAnf.KdArtiID), Vsa.ID, VsaAnf.Bestand, VsaAnf.BestandIst;

    UPDATE y SET y.AnzLsUngedruckt = x.Menge
    FROM #OpTeilMeng y, (
      SELECT LsKo.VsaID, LsPo.KdArtiID, SUM(LsPo.Menge) Menge 
      FROM LsKo, LsPo 
      WHERE LsKo.Status < N'O'
        AND LsKo.ID = LsPo.LsKOID
        AND LsKo.VsaID IN (SELECT VsaID FROM #OpTeilMeng)
        AND LsPo.KdArtiID IN (SELECT KdArtiID FROM #OpTeilMeng)
      GROUP BY LsKo.VsaID, LsPo.KdArtiID
    ) AS x
    WHERE y.KdArtiID = x.KdArtiID
      AND y.VsaID = x.VsaID;

    UPDATE VsaAnf SET BestandIst = x.BestandIst, VomIstBestandErsatz = x.VomIstBestandErsatz, IstBestandOrig = x.IstBestandOrig
    FROM #OpTeilMeng x
    WHERE VsaAnf.ID = x.VsaAnfID
      AND (VsaAnf.BestandIst <> x.BestandIst OR VsaAnf.VomIstBestandErsatz <> x.VomIstBestandErsatz OR VsaAnf.IstBestandOrig <> x.IstBestandOrig);
  END TRY
  BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState, ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine, ERROR_MESSAGE() AS ErrorMessage; 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
  END CATCH;
IF @@TRANCOUNT > 0 COMMIT;

GO