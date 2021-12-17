DECLARE @ChangeLog TABLE (
  VsaAnfID int,
  Montag float,
  Dienstag float,
  Mittwoch float,
  Donnerstag float,
  Freitag float,
  Samstag float,
  SollPuffer float
);

WITH FixmengenImportOtto AS (
  SELECT _FixmengenOtto.KdNr, _FixmengenOtto.VsaNr, _FixmengenOtto.ArtikelNr, _FixmengenOtto.Groesse, MAX(_FixmengenOtto.Montag) AS Montag, MAX(_FixmengenOtto.Dienstag) AS Dienstag, MAX(_FixmengenOtto.Mittwoch) AS Mittwoch, MAX(_FixmengenOtto.Donnerstag) AS Donnerstag, MAX(_FixmengenOtto.Freitag) AS Freitag, MAX(_FixmengenOtto.Samstag) AS Samstag, MAX(_FixmengenOtto.SollPuffer) AS SollPuffer
  FROM Salesianer.dbo._FixmengenOtto
  GROUP BY _FixmengenOtto.KdNr, _FixmengenOtto.VsaNr, _FixmengenOtto.ArtikelNr, _FixmengenOtto.Groesse
)
UPDATE VsaAnf SET
  Liefern1 = FixmengenImportOtto.Montag,
  Liefern2 = FixmengenImportOtto.Dienstag,
  Liefern3 = FixmengenImportOtto.Mittwoch,
  Liefern4 = FixmengenImportOtto.Donnerstag,
  Liefern5 = FixmengenImportOtto.Freitag,
  Liefern6 = FixmengenImportOtto.Samstag,
  SollPuffer = FixmengenImportOtto.SollPuffer
OUTPUT deleted.ID, deleted.Liefern1, deleted.Liefern2, deleted.Liefern3, deleted.Liefern4, deleted.Liefern5, deleted.Liefern6, deleted.SollPuffer
INTO @ChangeLog (VsaAnfID, Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, SollPuffer)
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN FixmengenImportOtto ON Kunden.kdNr = FixmengenImportOtto.KdNr AND Vsa.VsaNr = FixmengenImportOtto.VsaNr AND Artikel.ArtikelNr = FixmengenImportOtto.ArtikelNr AND ArtGroe.Groesse = FixmengenImportOtto.Groesse
WHERE (FixmengenImportOtto.Montag != VsaAnf.Liefern1 OR FixmengenImportOtto.Dienstag != VsaAnf.Liefern2 OR FixmengenImportOtto.Mittwoch != VsaAnf.Liefern3 OR FixmengenImportOtto.Donnerstag != VsaAnf.Liefern4 OR FixmengenImportOtto.Freitag != VsaAnf.Liefern5 OR FixmengenImportOtto.Samstag != VsaAnf.Liefern6 OR FixmengenImportOtto.SollPuffer != VsaAnf.SollPuffer);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, ChangeLog.Montag AS [Montag alt], CAST(VsaAnf.Liefern1 AS float) AS [Montag neu], ChangeLog.Dienstag AS [Dienstag alt], CAST(VsaAnf.Liefern2 AS float) AS [Dienstag neu], ChangeLog.Mittwoch AS [Mittwoch alt], CAST(VsaAnf.Liefern3 AS float) AS [Mittwoch neu], ChangeLog.Donnerstag AS [Donnerstag alt], CAST(VsaAnf.Liefern4 AS float) AS [Donnerstag neu], ChangeLog.Freitag AS [Freitag alt], CAST(VsaAnf.Liefern5 AS float) AS [Freitag neu], ChangeLog.Samstag AS [Samstag alt], CAST(VsaAnf.Liefern6 AS float) AS [Samstag neu], ChangeLog.SollPuffer AS [Soll-Puffer alt], CAST(VsaAnf.SollPuffer AS float) AS [Soll-Puffer neu]
FROM @ChangeLog AS ChangeLog
JOIN VsaAnf ON ChangeLog.VsaAnfID = VsaAnf.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikel.ArtikelNr, GroePo.Folge;

GO