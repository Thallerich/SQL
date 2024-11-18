DECLARE @von datetime = $2$;
DECLARE @bis datetime = DATEADD(day, 1, $2$);

WITH ExpScan AS (
  SELECT Scans.EinzHistID, Scans.[DateTime] AS Zeitpunkt
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN @von AND @bis
    AND Scans.ActionsID = 2
)
SELECT L.KdNr, L.SuchCode, L.VsaID, L.VsaNr, L.Vsa, L.Nachname, L.Vorname, L.ZimmerNr, L.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.ID AS VsaID, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr AS ZimmerNr, EinzHist.Barcode, EinzHist.ID AS TeileID, EinzHist.KdArtiID, Scans.Zeitpunkt
  FROM ExpScan AS Scans, EinzHist, Traeger, Vsa, Kunden
  WHERE Scans.EinzHistID = EinzHist.ID
    AND EinzHist.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.ID = $1$
) L, KdArti, LiefArt, Artikel
WHERE L.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.LiefArtID = LiefArt.ID
  AND LiefArt.LiefArt = 'H'
ORDER BY L.KdNr, L.VsaID, L.VsaNr, L.ZimmerNr, L.Nachname, L.Vorname , Artikel.ArtikelNr, L.TeileID;