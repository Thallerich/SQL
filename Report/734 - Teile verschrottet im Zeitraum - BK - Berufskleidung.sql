DROP TABLE IF EXISTS #TmpErgebnis734;

SELECT WegGrund.WegGrundBez$LAN$ AS Grund, Teile.Barcode, [Status].StatusBez AS [Status], Teile.ErstWoche, Teile.ErstDatum, Teile.PatchDatum, Teile.Ausdienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS SGF, Teile.AusdRestw AS RestWert
INTO #TmpErgebnis734
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Status] ON  Teile.[Status] = [Status].[Status] AND [Status].Tabelle = 'TEILE'
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN WegGrund ON Teile.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
  AND Kunden.KdGfID IN ($4$)
  AND Teile.[Status] = 'Y'
  AND WegGrund.ID IN ($3$)
  AND Teile.AusDienstDat BETWEEN $1$ AND $2$
  AND Bereich.ID IN ($5$);

INSERT INTO #TmpErgebnis734
SELECT WegGrund.WegGrundBez$LAN$ AS Grund, TeileLag.Barcode, [Status].StatusBez AS [Status], TeileLag.ErstWoche, TeileLag.ErstDatum, CONVERT(date, NULL) AS PatchDatum, TeileLag.AusDienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS SGF, TeileLag.Restwert AS RestWert
FROM TeileLag
JOIN [Status] ON TeileLag.[Status] = [Status].[Status] AND [Status].Tabelle = 'TEILELAG'
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN WegGrund ON TeileLag.WegGrundID = WegGrund.ID
JOIN Traeger ON TeileLag.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
WHERE TeileLag.[Status] = 'Y'
  AND Kunden.KdGfID IN ($4$)
  AND Bereich.ID IN ($5$)
  AND WegGrund.ID IN ($3$)
  AND TeileLag.AusDienstDat BETWEEN $1$ AND $2$
  AND NOT EXISTS (
    SELECT Ergebnis.Barcode
    FROM #TmpErgebnis734 Ergebnis
    WHERE Ergebnis.Barcode = TeileLag.Barcode
  );

SELECT *
FROM #TmpErgebnis734
ORDER BY Kdnr, VsaNr, ArtikelNr;