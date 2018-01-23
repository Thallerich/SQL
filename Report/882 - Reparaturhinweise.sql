DECLARE @EingabeDatumVon datetime;
DECLARE @EingabeDatumBis datetime;

SET @EingabeDatumVon = $1$;
SET @EingabeDatumBis = DATEADD(day, 1, $2$);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Teile.Barcode, Teile.RestwertInfo AS RestwertAktuell, Hinweis.Hinweis, Hinweis.Aktiv, CONVERT(date, Hinweis.EingabeDatum) AS [Hinweis erfasst am], EingabeMitarbei.Name AS [Erfasst von], CONVERT(date, Hinweis.BestaetDatum) AS [Bestätigt am], BestaetMitarbei.Name AS [Bestätigt von]
FROM Hinweis, Teile, Vsa, Kunden, KdGf, Artikel, Mitarbei AS EingabeMitarbei, Mitarbei AS BestaetMitarbei
WHERE Hinweis.TeileID = Teile.ID
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Hinweis.EingabeMitarbeiID = EingabeMitarbei.ID
  AND Hinweis.BestaetMitarbeiID = BestaetMitarbei.ID
  AND Hinweis.HinwTextID IN ($3$)
  AND Hinweis.EingabeDatum BETWEEN @EingabeDatumVon AND @EingabeDatumBis
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);