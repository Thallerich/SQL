/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ prepareData                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Teile976b;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ aktuelle Austausch-Teile                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT KdGf.KurzBez AS Geschäftsbereich,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  EinzHist.Barcode,
  Teilestatus.StatusBez AS [Status Teil],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.Ausdienst AS [Außerdienststellungs-Woche],
  EinzHist.AusdienstDat AS [Außerdienststellungs-Datum],
  CAST(NULL AS nvarchar(60)) AS [Außerdienststellungs-Grund],
  WegGrund.WeggrundBez$LAN$ AS [Schrott-Grund],
  EinzHist.RestwertInfo AS Restwert,
  [Week].Woche AS [Ersteinsatz-Woche],
  EinzTeil.ErstDatum AS [Ersteinsatz-Datum],
  EinzHist.Indienst AS [Indienststellungs-Woche],
  EinzHist.IndienstDat AS [Indienststellungs-Datum],
  EinzHist.PatchDatum AS [Patch-Datum],
  EinzHist.Kostenlos,
  EinzHist.RuecklaufK AS [Anzahl Wäschen aktueller Träger],
  EinzTeil.RuecklaufG AS [Anzahl Wäschen gesamte Lebensdauer],
  Produktion.Bez AS Produktion,
  Kundenservice.Bez AS [Kundenservice-Standort],
  CAST(0 AS bit) AS Berechnet,
  N'Austausch' AS Art,
  Mitarbeiter = (
    SELECT TOP 1 Mitarbei.Name
    FROM Scans
    JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.ActionsID = 4
    ORDER BY Scans.[DateTime] DESC
  )
INTO #Teile976b
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN [Week] ON DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE EinzTeil.AltenheimModus = 0
  AND EinzHist.[Status] = N'S'
  AND Produktion.ID IN ($3$)
  AND Kundenservice.ID IN ($4$)
  AND KdGf.ID IN ($5$)
  AND Holding.ID IN ($6$);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ vergangenge Austausch-Teile                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
INSERT INTO #Teile976b
SELECT KdGf.KurzBez AS Geschäftsbereich,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  EinzHist.Barcode,
  Teilestatus.StatusBez AS [Status Teil],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.Ausdienst AS [Außerdienststellungs-Woche],
  EinzHist.AusdienstDat AS [Außerdienststellungs-Datum],
  Einsatz.EinsatzBez$LAN$ AS [Außerdienststellungs-Grund],
  WegGrund.WeggrundBez$LAN$ AS [Schrott-Grund],
  EinzHist.RestwertInfo AS Restwert,
  [Week].Woche AS [Ersteinsatz-Woche],
  EinzTeil.ErstDatum AS [Ersteinsatz-Datum],
  EinzHist.Indienst AS [Indienststellungs-Woche],
  EinzHist.IndienstDat AS [Indienststellungs-Datum],
  EinzHist.PatchDatum AS [Patch-Datum],
  EinzHist.Kostenlos,
  EinzHist.RuecklaufK AS [Anzahl Wäschen aktueller Träger],
  EinzTeil.RuecklaufG AS [Anzahl Wäschen gesamte Lebensdauer],
  Produktion.Bez AS Produktion,
  Kundenservice.Bez AS [Kundenservice-Standort],
  Berechnet = CASE
    WHEN EXISTS (SELECT TeilSoFa.ID FROM TeilSoFa WHERE TeilSoFa.EinzHistID = EinzHist.ID AND TeilSoFa.SoFaArt = N'R' AND TeilSoFa.[Status] IN (N'L', N'P')) THEN 1
    ELSE 0
  END,
  N'Austausch' AS Art,
  Mitarbeiter = (
    SELECT TOP 1 Mitarbei.Name
    FROM Scans
    JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.ActionsID = 4
    ORDER BY Scans.[DateTime] DESC
  )
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN [Week] ON DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE EinzTeil.AltenheimModus = 0
  AND EinzHist.[Status] > N'S'
  AND EinzHist.AusdienstGrund IN (N'A', N'a', N'B', N'b', N'C', N'c', N'E', N'e')
  AND EinzHist.AusdienstDat BETWEEN $1$ AND $2$
  AND Produktion.ID IN ($3$)
  AND Kundenservice.ID IN ($4$)
  AND KdGf.ID IN ($5$)
  AND Holding.ID IN ($6$);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Schrott-Teile                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
INSERT INTO #Teile976b
SELECT KdGf.KurzBez AS Geschäftsbereich,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  EinzHist.Barcode,
  Teilestatus.StatusBez AS [Status Teil],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.Ausdienst AS [Außerdienststellungs-Woche],
  EinzHist.AusdienstDat AS [Außerdienststellungs-Datum],
  Einsatz.EinsatzBez$LAN$ AS [Außerdienststellungs-Grund],
  WegGrund.WeggrundBez$LAN$ AS [Schrott-Grund],
  EinzHist.RestwertInfo AS Restwert,
  [Week].Woche AS [Ersteinsatz-Woche],
  EinzTeil.ErstDatum AS [Ersteinsatz-Datum],
  EinzHist.Indienst AS [Indienststellungs-Woche],
  EinzHist.IndienstDat AS [Indienststellungs-Datum],
  EinzHist.PatchDatum AS [Patch-Datum],
  EinzHist.Kostenlos,
  EinzHist.RuecklaufK AS [Anzahl Wäschen aktueller Träger],
  EinzTeil.RuecklaufG AS [Anzahl Wäschen gesamte Lebensdauer],
  Produktion.Bez AS Produktion,
  Kundenservice.Bez AS [Kundenservice-Standort],
  Berechnet = CASE
    WHEN EXISTS (SELECT TeilSoFa.ID FROM TeilSoFa WHERE TeilSoFa.EinzHistID = EinzHist.ID AND TeilSoFa.SoFaArt = N'R' AND TeilSoFa.[Status] IN (N'L', N'P')) THEN 1
    ELSE 0
  END,
  N'Austausch' AS Art,
  Mitarbeiter = (
    SELECT TOP 1 Mitarbei.Name
    FROM Scans
    JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
    WHERE Scans.EinzHistID = EinzHist.ID
      AND Scans.ActionsID = 7
    ORDER BY Scans.[DateTime] DESC
  )
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Kundenservice ON Kunden.StandortID = Kundenservice.ID
JOIN [Week] ON DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE EinzTeil.AltenheimModus = 0
  AND EinzHist.[Status] = N'Y'
  AND EinzHist.AusdienstDat BETWEEN $1$ AND $2$
  AND Produktion.ID IN ($3$)
  AND Kundenservice.ID IN ($4$)
  AND KdGf.ID IN ($5$)
  AND Holding.ID IN ($6$);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reportdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT * FROM #Teile976b;