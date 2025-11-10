SELECT WegGrund.WegGrundBez$LAN$ AS Grund, EinzHist.Barcode, [Status].StatusBez AS [Status], Week.Woche AS ErstWoche, Einzteil.ErstDatum, EinzHist.PatchDatum, EinzHist.Ausdienst, EinzHist.AusdienstDat, Artikel.ArtikelNr, Artikel.ArtikelNr2, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, ArtMisch.ArtMischBez AS Gewebe, ArtMisch.Gewicht AS [Flächengewicht g/m²], Artikel.StueckGewicht AS [Gewicht kg/Stück], ArtGru.ArtGruBez AS Artikelgruppe, Bereich.BereichBez AS Produktbereich, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenservice.Bez AS [Kundenservice-Standort], KdGf.KurzBez AS Geschäftsbereich, EinzHist.AusdRestw AS Restwert, Einzteil.AlterInfo as [Alter des Teils in Wochen], Einzhist.AnzRepair as [Anzahl Reparaturen Gesamt], Einzteil.RuecklaufG AS [Anzahl Wäschen gesamt], EinzHist.RuecklaufK AS [Anzahl Wäschen Kunde], EinzHist.Kostenlos, CAST(IIF(ISNULL(TeilSoFa.ID, -1) > 0, 1, 0) AS bit) AS [Restwert berechnet?], RWArt.RWArtBez$LAN$ AS [Restwert-Art]
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Status] ON EinzHist.[Status] = [Status].[Status] AND [Status].Tabelle = 'EINZHIST'
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtMisch ON Artikel.ArtMischID = ArtMisch.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN [Week] ON DATEADD(day, Einzteil.AnzTageImLager, Einzteil.ErstDatum) BETWEEN [Week].VonDat AND [Week].BisDat
LEFT JOIN TeilSoFa ON TeilSoFa.EinzHistID = EinzHist.ID AND TeilSoFa.SoFaArt = N'R' AND (TeilSoFa.RechPoID > 0 OR (TeilSoFa.Status IN (N'L', N'P') AND TeilSoFa.OhneBerechGrund = 0))
LEFT JOIN RWArt ON RWArt.ID = TeilSoFa.RwArtID
WHERE Kunden.KdGfID IN ($4$)
  AND EinzHist.[Status] = N'Y'
  AND EinzHist.EinzHistTyp = 1 /* ausgeschieden */
  AND WegGrund.ID IN ($3$)
  AND EinzHist.AusDienstDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Produktion.ID IN ($7$)
  AND Artikel.ID IN ($6$);