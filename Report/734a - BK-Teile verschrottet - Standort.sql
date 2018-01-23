DROP TABLE IF EXISTS #TmpErgebnis;

SELECT WegGrund.WegGrundBez$LAN$ AS Schrottgrund, Teile.Barcode, Status.StatusBez AS Status, Teile.ErstWoche, Teile.ErstDatum, Teile.PatchDatum, Teile.Ausdienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Standort, Teile.AusdRestw AS RestWert
INTO #TmpErgebnis
FROM Teile, Vsa, Kunden, Status, Artikel, WegGrund, Standort, Bereich
WHERE Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.StandortID = Standort.ID
	AND Standort.ID IN ($4$)
	AND Teile.Status = Status.Status
	AND Status.Tabelle = 'TEILE'
	AND Teile.ArtikelID = Artikel.ID
	AND Teile.Status = 'Y'
	AND Teile.WegGrundID = WegGrund.ID
  AND WegGrund.ID IN ($3$)
	AND Teile.AusDienstDat BETWEEN $1$ AND $2$
	AND Artikel.BereichID = Bereich.ID
	AND Bereich.ID IN ($5$);

INSERT INTO #TmpErgebnis
SELECT WegGrund.WegGrundBez$LAN$ AS Schrottgrund, TeileLag.Barcode, Status.StatusBez AS Status, TeileLag.ErstWoche, TeileLag.ErstDatum, CONVERT(date, NULL) AS PatchDatum, TeileLag.AusDienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Standort, TeileLag.Restwert AS RestWert
FROM TeileLag, Status, ArtGroe, Artikel, WegGrund, Traeger, Vsa, Kunden, Standort, Bereich
WHERE TeileLag.Status = Status.Status
	AND Status.Tabelle = 'TEILELAG'
	AND TeileLag.Status = 'Y'
	AND TeileLag.ArtGroeID = ArtGroe.ID
	AND ArtGroe.ArtikelID = Artikel.ID
	AND Artikel.BereichID = Bereich.ID
	AND Bereich.ID IN ($5$)
	AND TeileLag.WegGrundID = WegGrund.ID
  AND WegGrund.ID IN ($3$)
	AND TeileLag.AusDienstDat BETWEEN $1$ AND $2$
	AND TeileLag.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.StandortID = Standort.ID
	AND Standort.ID IN ($4$)
  AND NOT EXISTS (
    SELECT Ergebnis.Barcode
    FROM #TmpErgebnis Ergebnis
    WHERE Ergebnis.Barcode = TeileLag.Barcode
  );

SELECT Standort, ArtikelNr, ArtikelNr2 AS [BMD-ArtikelNr], Artikelbezeichnung, EKPreis, Schrottgrund, COUNT(Barcode) AS Menge
FROM #TmpErgebnis
GROUP BY Standort, ArtikelNr, ArtikelNr2, Artikelbezeichnung, EKPreis, Schrottgrund
ORDER BY Standort, ArtikelNr;