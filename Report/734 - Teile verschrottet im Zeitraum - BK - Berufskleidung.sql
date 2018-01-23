BEGIN TRY
  DROP TABLE #TmpErgebnis;
END TRY
BEGIN CATCH
END CATCH;

SELECT WegGrund.WegGrundBez$LAN$ AS Grund, Teile.Barcode, Status.StatusBez AS Status, Teile.ErstWoche, Teile.ErstDatum, Teile.PatchDatum, Teile.Ausdienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS SGF, Teile.AusdRestw AS RestWert
INTO #TmpErgebnis
FROM Teile, Vsa, Kunden, Status, Artikel, WegGrund, KdGf, Bereich
WHERE Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdGfID = KdGf.ID
	AND Kunden.KdGfID IN ($4$)
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
SELECT WegGrund.WegGrundBez$LAN$ AS Grund, TeileLag.Barcode, Status.StatusBez AS Status, TeileLag.ErstWoche, TeileLag.ErstDatum, CONVERT(date, NULL) AS PatchDatum, TeileLag.AusDienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS SGF, TeileLag.Restwert AS RestWert
FROM TeileLag, Status, ArtGroe, Artikel, WegGrund, Traeger, Vsa, Kunden, KdGf, Bereich
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
	AND Kunden.KdGfID = KdGf.ID
	AND Kunden.KdGfID IN ($4$)
  AND NOT EXISTS (
    SELECT Ergebnis.Barcode
    FROM #TmpErgebnis Ergebnis
    WHERE Ergebnis.Barcode = TeileLag.Barcode
  );

SELECT *
FROM #TmpErgebnis
ORDER BY Kdnr, VsaNr, ArtikelNr;