-- Pipeline 1
DROP TABLE IF EXISTS #TmpErgebnis734;

--Pipeline 2
CREATE TABLE #TmpErgebnis734 (
  Grund nvarchar(60) COLLATE Latin1_General_CS_AS,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  [Status] nvarchar(40) COLLATE Latin1_General_CS_AS,
  ErstWoche nchar(7) COLLATE Latin1_General_CS_AS,
  ErstDatum date,
  PatchDatum date,
  Ausdienst nchar(7) COLLATE Latin1_General_CS_AS,
  AusdienstDat date,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelNr2 nvarchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  EKPreis money,
  VsaNr int,
  [VSA-Stichwort] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [VSA-Bezeichnung] nvarchar(40) COLLATE Latin1_General_CS_AS,
  Produktionsstandort nvarchar(40) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  [Kundenservice-Standort] nvarchar(40) COLLATE Latin1_General_CS_AS,
  Geschäftsbereich nvarchar(5) COLLATE Latin1_General_CS_AS,
  Restwert money,
  [Anzahl Wäschen gesamt] int,
  [Anzahl Wäschen Kunde] int,
  Kostenlos bit,
  Mitarbeiter nvarchar(40) COLLATE Latin1_General_CS_AS
);

INSERT INTO #TmpErgebnis734 (Grund, Barcode, [Status], ErstWoche, ErstDatum, PatchDatum, Ausdienst, AusdienstDat, ArtikelNr, ArtikelNr2, Artikelbezeichnung, EKPreis, VsaNr, [VSA-Stichwort], [VSA-Bezeichnung], Produktionsstandort, KdNr, Kunde, [Kundenservice-Standort], Geschäftsbereich, Restwert, [Anzahl Wäschen gesamt], [Anzahl Wäschen Kunde], Kostenlos, Mitarbeiter)
SELECT  WegGrund.WegGrundBez$LAN$ AS Grund, Teile.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, Teile.ErstDatum, Teile.PatchDatum, Teile.Ausdienst, Teile.AusdienstDat, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS Geschäftsbereich, Teile.AusdRestw AS Restwert, Teile.RuecklaufG AS [Anzahl Wäschen gesamt], Teile.RuecklaufK AS [Anzahl Wäschen Kunde], Teile.Kostenlos, Mitarbei.Name AS Mitarbeiter
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
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
LEFT JOIN Scans ON Scans.TeileID = Teile.ID AND Scans.ActionsID = 7
LEFT JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE Kunden.KdGfID IN ($4$)
  AND Teile.[Status] = N'Y'
  AND WegGrund.ID IN ($3$)
  AND Teile.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Bereich.ID IN ($5$);

INSERT INTO #TmpErgebnis734 (Grund, Barcode, [Status], ErstWoche, ErstDatum, PatchDatum, Ausdienst, AusdienstDat, ArtikelNr, ArtikelNr2, Artikelbezeichnung, EKPreis, VsaNr, [VSA-Stichwort], [VSA-Bezeichnung], Produktionsstandort, KdNr, Kunde, [Kundenservice-Standort], Geschäftsbereich, Restwert, [Anzahl Wäschen gesamt], [Anzahl Wäschen Kunde], Kostenlos, Mitarbeiter)
SELECT WegGrund.WegGrundBez$LAN$ AS Grund, TeileLag.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, TeileLag.ErstDatum, CONVERT(date, NULL) AS PatchDatum, TeileLag.AusDienst, TeileLag.AusdienstDat, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS Geschäftsbereich, TeileLag.Restwert AS Restwert, TeileLag.AnzWaschen AS [Anzahl Wäschen gesamt], NULL AS [Anzahl Wäschen Kunde], NULL AS Kostenlos, NULL AS Mitarbeiter
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
JOIN Week ON DATEADD(day, TeileLag.AnzTageImLager, TeileLag.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE TeileLag.[Status] = N'Y'
  AND Kunden.KdGfID IN ($4$)
  AND Bereich.ID IN ($5$)
  AND WegGrund.ID IN ($3$)
  AND TeileLag.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND NOT EXISTS (
    SELECT Ergebnis.Barcode
    FROM #TmpErgebnis734 Ergebnis
    WHERE Ergebnis.Barcode = TeileLag.Barcode
  );

-- Pipeline 3
SELECT *
FROM #TmpErgebnis734
ORDER BY Kdnr, VsaNr, ArtikelNr;