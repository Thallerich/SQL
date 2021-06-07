DROP TABLE IF EXISTS #TmpErgebnis734a;

SELECT WegGrund.WegGrundBez$LAN$ AS Schrottgrund, Teile.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, Teile.ErstDatum, Teile.PatchDatum, Teile.Ausdienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], Teile.AusdRestw AS RestWert
INTO #TmpErgebnis734a
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [Status] ON Teile.[Status] = [Status].[Status] AND [Status].Tabelle = 'TEILE'
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN WegGrund ON Teile.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE Produktion.ID IN ($4$)
  AND Teile.[Status] = 'Y'
  AND WegGrund.ID IN ($3$)
  AND Teile.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Bereich.ID IN ($5$);

INSERT INTO #TmpErgebnis734a
SELECT WegGrund.WegGrundBez$LAN$ AS Schrottgrund, TeileLag.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, TeileLag.ErstDatum, CONVERT(date, NULL) AS PatchDatum, TeileLag.AusDienst, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], TeileLag.Restwert AS RestWert
FROM TeileLag
JOIN [Status] ON TeileLag.[Status] = [Status].[Status] AND [Status].Tabelle = 'TEILELAG'
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN WegGrund ON TeileLag.WegGrundID = WegGrund.ID
JOIN Traeger ON TeileLag.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN Week ON DATEADD(day, TeileLag.AnzTageImLager, TeileLag.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE TeileLag.[Status] = 'Y'
  AND Bereich.ID IN ($5$)
  AND WegGrund.ID IN ($3$)
  AND TeileLag.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Produktion.ID IN ($4$)
  AND NOT EXISTS (
    SELECT Ergebnis.Barcode
    FROM #TmpErgebnis734a Ergebnis
    WHERE Ergebnis.Barcode = TeileLag.Barcode
  );

SELECT Produktionsstandort, ArtikelNr, ArtikelNr2 AS [BMD-ArtikelNr], Artikelbezeichnung, EKPreis, Schrottgrund, COUNT(Barcode) AS Menge
FROM #TmpErgebnis734a
GROUP BY Produktionsstandort, ArtikelNr, ArtikelNr2, Artikelbezeichnung, EKPreis, Schrottgrund
ORDER BY Produktionsstandort, ArtikelNr;