DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], EinzHist.Barcode, Teilestatus.StatusBez AS [Status des Teils], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status des Trägers], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Vsa.GebaeudeBez AS Abteilung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, EinzTeil.LastScanTime AS [Datum Ausgabe], CAST(LeasProWo.LeasPreisProWo AS float) AS [Leasing pro Woche], CAST(RwCalc.RestwertInfo AS float) AS Restwert
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
CROSS APPLY advFunc_GetLeasPreisProWo(EinzHist.KdArtiID) AS LeasProWo
CROSS APPLY funcGetRestwert(EinzHist.ID, @Woche, 1) AS RwCalc
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
WHERE Holding.Holding LIKE N'VOES%'
  AND EinzHist.Status BETWEEN N'Q' AND N'W'
  AND EinzHist.Einzug IS NULL
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
  AND Traeger.ParentTraegerID > 0
  AND Vsa.VsaNr = 902
  AND EinzTeil.LastScanTime < DATEADD(month, -3, GETDATE());