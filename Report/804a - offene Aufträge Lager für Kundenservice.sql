/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: PrepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Result804a;

DECLARE @fromdate datetime2 = CAST($STARTDATE$ AS datetime2);
DECLARE @todate date = DATEADD(day, 1, CAST($ENDDATE$ AS datetime2));

CREATE TABLE #Result804a (
  ServiceMA nvarchar(40),
  BetreuerMA nvarchar(40),
  KdNr int,
  Kunde nvarchar(20),
  Holding nvarchar(10),
  Nachname nvarchar(40),
  Vorname nvarchar(20),
  Trägerstatus nvarchar(40),
  Barcode nvarchar(33),
  Teilestatus nvarchar(40),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Größe nvarchar(12),
  Anlage datetime2,
  ABTermin date,
  Entnahmeliste int,
  EntnahmeAnlage datetime2,
  EntnahmeDruck datetime2,
  EntnhameZeit datetime2,
  EntnahmePatch datetime2,
  Einsatzgrund nvarchar(60)
);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
INSERT INTO #Result804a (ServiceMA, BetreuerMA, KdNr, Kunde, Holding, Nachname, Vorname, Trägerstatus, Barcode, Teilestatus, ArtikelNr, Artikelbezeichnung, Größe, Anlage, ABTermin, Entnahmeliste, EntnahmeAnlage, EntnahmeDruck, EntnhameZeit, EntnahmePatch, Einsatzgrund)
SELECT ServiceMA.Name AS ServiceMA, BetreuerMA.Name AS BetreuerMA, Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS Trägerstatus, EinzHist.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Anlage_ AS Anlage, LiefAbPo.Termin AS ABTermin, EntnKo.ID AS Entnahmeliste, EntnKo.Anlage_ AS EntnahmeAnlage, EntnKo.DruckDatum AS EntnahmeDruck, EntnahmeZeit = (
  SELECT MAX(Scans.[DateTime])
  FROM Scans
  WHERE Scans.EinzHistID = EinzHist.ID
    AND Scans.ActionsID = 57
), EntnKo.PatchDatum AS EntnahmePatch, Einsatz.EinsatzBez$LAN$ AS Einsatzgrund
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS ServiceMA ON KdBer.ServiceID = ServiceMA.ID
JOIN Mitarbei AS BetreuerMA ON KdBer.BetreuerID = BetreuerMA.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Einsatz ON EinzHist.EinsatzGrund = Einsatz.EinsatzGrund
LEFT JOIN EntnPo ON EinzHist.EntnPoID = EntnPo.ID AND EinzHist.EntnPoID > 0
LEFT JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
LEFT JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID AND TeileBPo.Latest = 1
LEFT JOIN BPo ON TeileBPo.BPoID = BPo.ID
LEFT JOIN BKo ON BPo.BKoID = BKo.ID
LEFT JOIN LiefAbPo ON BPo.LatestLiefABKoID = LiefAbPo.LiefABKoID AND BPo.ID = LiefAbPo.BPoID
WHERE EinzHist.Anlage_ > CAST(N'2019-04-01 00:00:00' AS datetime2)
  AND Artikel.BereichID = 100
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND Traeger.Status != N'I'
  AND Teilestatus.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$)
  AND Kunden.StandortID IN ($3$)
  AND ServiceMA.ID IN ($4$)
  AND BetreuerMA.ID IN ($5$)
  AND EinzHist.Anlage_ BETWEEN @fromdate AND @todate;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT ServiceMA AS [Kundenservice-Mitarbeiter], BetreuerMA AS Betreuer, KdNr, Kunde, Holding, Nachname, Vorname, Trägerstatus, Barcode, Teilestatus, ArtikelNr, Artikelbezeichnung, Größe, Anlage AS [Teil angelegt am], ABTermin AS [Termin Auftragsbestätigung], Entnahmeliste AS EntnahmelistenNr, EntnahmeAnlage AS [Entnahmeliste angelegt am], EntnahmeDruck AS [Druckdatum Entnahmeliste], EntnhameZeit AS [Entnahme-Datum], EntnahmePatch AS [Patchdatum Entnahmeliste], Einsatzgrund
FROM #Result804a
ORDER BY [Entnahmeliste angelegt am];