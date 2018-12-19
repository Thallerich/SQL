DECLARE @von datetime = $2$;
DECLARE @bis datetime = DATEADD(day, 1, $2$);

DROP TABLE IF EXISTS #TmpScans_Rep830;

SELECT Scans.TeileID, Scans.DateTime AS Zeitpunkt
INTO #TmpScans_Rep830
FROM Scans
WHERE Scans.DateTime BETWEEN @von AND @bis
  AND Scans.ZielNrID = 2;

SELECT L.KdNr, L.SuchCode, L.VsaID, L.VsaNr, L.Vsa, L.Nachname, L.Vorname, L.ZimmerNr, L.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.ID AS VsaID, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr AS ZimmerNr, Teile.Barcode, Teile.ID AS TeileID, Teile.KdArtiID, Scans.Zeitpunkt
  FROM #TmpScans_Rep830 Scans, Teile, Traeger, Vsa, Kunden
  WHERE Scans.TeileID = Teile.ID
    AND Teile.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.ID = $1$
) L, KdArti, LiefArt, Artikel
WHERE L.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.LiefArtID = LiefArt.ID
  AND LiefArt.LiefArt = 'H'
ORDER BY L.KdNr, L.VsaID, L.VsaNr, L.ZimmerNr, L.Nachname, L.Vorname , Artikel.ArtikelNr, L.TeileID;