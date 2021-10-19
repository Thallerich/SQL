DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @VsaAnfKorr TABLE (
  VsaAnfID int,
  BestandIst int,
  Bestand int
);

DECLARE @Changelog TABLE (
  VsaAnfID int,
  BestandAlt int,
  BestandIstAlt int,
  BestandNeu int,
  BestandIstNeu int
);

INSERT INTO @VsaAnfKorr (VsaAnfID, BestandIst, Bestand)
SELECT VsaAnf.ID, COUNT(Daten.ID) AS BestandIst, IIF(VsaAnf.Bestand = 0, 0, VsaAnf.BestandIst - (VsaAnf.BestandIst % Artikel.Packmenge) + IIF(VsaAnf.BestandIst % Artikel.Packmenge = 0, 0, Artikel.Packmenge)) AS Bestand
--SELECT Kunden.KdNr, Vsa.SuchCode AS [Vsa-Stichwort], vsa.VsaNr AS VSANr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez ArtikelBez, daten.Artikelgr AS Größe, VsaAnf.Bestand SollBestand, VsaAnf.BestandIst [Ist-Bestand aktuell], COUNT(Daten.ID) AS [Ist-Bestand neu], VsaAnf.ID AS VsaAnfID, IIF(VsaAnf.Bestand = 0, 0, VsaAnf.BestandIst - (VsaAnf.BestandIst % Artikel.Packmenge) + IIF(VsaAnf.BestandIst % Artikel.Packmenge = 0, 0, Artikel.Packmenge)) AS [Sollbestand neu]
FROM (
  SELECT OpTeile.ID, OpTeile.VsaID, OpTeile.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass, OpTeile.LastErsatzArtGroeID ArtGroeID, '-' AS Artikelgr
  FROM OpTeile, KdArti, Vsa
  WHERE OpTeile.LastErsatzFuerKdArtiID > - 1
    AND OpTeile.LastErsatzFuerKdArtiID = KdArti.ID
    AND OpTeile.LastActionsID IN (102, 120, 136) --OpTeile.LastActionsID = (ID_PRODSTAT_OPAUSLESEN oder ID_PRODSTAT_OP_INVENTUR oder ID_PRODSTAT_UHFWARENEINGANG_KUNDE)
    AND OpTeile.VsaID > 0
    AND OpTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = KdArti.KundenID
  
  UNION ALL
  
  SELECT OpTeile.ID, OpTeile.VsaID, OpTeile.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass, OpTeile.ArtGroeID, Artgroe.Groesse AS Artikelgr
  FROM OpTeile, ArtGroe, KdArti, Vsa
  WHERE OpTeile.LastErsatzFuerKdArtiID = - 1
    AND OpTeile.LastActionsID IN (102, 120, 136) --OpTeile.LastActionsID = (ID_PRODSTAT_OPAUSLESEN oder ID_PRODSTAT_OP_INVENTUR)--136 neu dazu
    AND OpTeile.VsaID > 0
    AND OpTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = KdArti.KundenID
    AND ArtGroe.ArtikelID = KdArti.ArtikelID
    AND OpTeile.ArtGroeID = ArtGroe.ID
  ) Daten, Vsa, kdber, vsaanf, Kunden, Artikel, Bereich
WHERE Vsa.ID = Daten.VsaID
  AND Vsa.KundenID = KdBer.KundenID
  AND Kunden.ID = Vsa.KundenID
  AND Daten.KdBerID = KdBer.ID
  AND Artikel.ID = Daten.ArtikelID
  AND (KdBer.IstBestandAnpass = 1 OR Daten.IstBestandAnpass = 1)
  AND EXISTS (
    --nur von Kunden, die generell einen Empfangsscan machen
    SELECT OPTeile.ID
    FROM OPTeile
    WHERE OPTeile.LastActionsID = 136
      AND OPTeile.VsaID = Vsa.ID
  )
  AND VsaAnf.VsaID = Vsa.ID
  AND VsaAnf.KdArtiID = Daten.KdArtiID
  AND KdBer.BereichID = Bereich.ID
  AND (VsaAnf.ArtGroeID = - 1 OR (Bereich.VsaAnfGroe = 1 AND VsaAnf.ArtGroeID = Daten.ArtGroeID))
GROUP BY Kunden.KdNr, Vsa.SuchCode, vsa.VsaNr, Vsa.Bez, daten.Artikelgr, Artikel.ArtikelNr, Artikel.ArtikelBez, Vsa.ID, VsaAnf.Bestand, VsaAnf.BestandIst, VsaAnf.ID, Artikel.PackMenge
HAVING COUNT(Daten.ID) != VsaAnf.BestandIst;

UPDATE VsaAnf SET BestandIst = VsaAnfKorr.BestandIst, Bestand = IIF(VsaAnf.Bestand >= VsaAnfKorr.Bestand, VsaAnf.Bestand, VsaAnfKorr.Bestand)
OUTPUT inserted.ID, deleted.Bestand, deleted.BestandIst, inserted.Bestand, inserted.BestandIst
INTO @Changelog (VsaAnfID, BestandAlt, BestandIstAlt, BestandNeu, BestandIstNeu)
FROM @VsaAnfKorr AS VsaAnfKorr
WHERE VsaAnfKorr.VsaAnfID = VsaAnf.ID;

INSERT INTO VsaAnfHi (VsaID, KdArtiID, Zeitpunkt, MitarbeiID, [Text], VertragDiff, ArtGroeID, AenderungsGrund, VsaAnfTpID, EPreis, UserID_)
SELECT VsaAnf.VsaID, VsaAnf.KdArtiID, GETDATE() AS Zeitpunkt, @UserID AS MitarbeiID, N'Korrektur-Skript ' + FORMAT(GETDATE(), N'dd.MM.yyyy'), Changelog.BestandNeu - Changelog.BestandAlt AS VertragDiff, VsaAnf.ArtGroeID, N'LEER' AS Aenderungsgrund, 10 AS VsaAnfTpID, Artikel.EkPreis AS Epreis, @UserID AS UserID_
FROM @Changelog AS Changelog
JOIN VsaAnf ON Changelog.VsaAnfID = VsaAnf.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Changelog.BestandAlt != Changelog.BestandNeu;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Changelog.BestandAlt AS [Vertragsbestand bisher], Changelog.BestandNeu AS [Vertragsbestand erhöht], Changelog.BestandIstAlt AS [Ist-Bestand bisher], Changelog.BestandIstNeu AS [Ist-Bestand korrigiert]
FROM @Changelog AS Changelog
JOIN VsaAnf ON Changelog.VsaAnfID = VsaAnf.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID;

GO