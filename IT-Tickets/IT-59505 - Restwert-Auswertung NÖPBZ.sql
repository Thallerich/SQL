DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH PoolteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZTEIL'
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Schwundteile.Code AS Code, COALESCE(PoolteilStatus.StatusBez, Teilestatus.StatusBez) AS [aktueller Status des Teils], Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Schwundteile.Vertragsartikel, CAST(Schwundteile.BasisAfa AS numeric(10, 4)) AS Basisrestwert, CAST(Schwundteile.RestwertInfo AS numeric(10, 4)) AS Restwert, CAST(Schwundteile.LastScanTime AS date) AS [letzter Scan], Actions.ActionsBez AS [letzte Aktion], DATEDIFF(day, Schwundteile.LastScanTime, GETDATE()) AS [Tage ohne Bewegung], Schwundteile.Erstwoche AS [Erster Einsatz], CAST(IIF(Schwundteile.RechPoID = -2, 1, 0) AS bit) AS [ohne Berrechnung?]
FROM (
  SELECT N'EINZTEIL' AS TableName, ArtGroe.ArtikelID, EinzTeil.ArtGroeID, EinzTeil.Status, EinzTeil.RechPoID, EinzTeil.VsaID, EinzTeil.Code, EinzTeil.LastScanTime, EinzTeil.Erstwoche, CAST(MAX(CAST(KdArti.Vertragsartikel AS int)) AS bit) AS Vertragsartikel, EinzTeil.LastActionsID, fRW.BasisAfa, fRW.RestwertInfo, CAST(0 AS bit) AS SetTeil
  FROM EinzTeil
  CROSS APPLY dbo.funcGetRestWertOP(EinzTeil.ID, @curweek, 1) fRW
  JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  JOIN KdArti ON ArtGroe.ArtikelID = KdArti.ArtikelID AND KdArti.KundenID = Vsa.KundenID
  WHERE ArtGroe.ArtikelID IN (SELECT ID FROM Artikel WHERE ArtikelNr IN (N'U82', N'U83', N'U84', N'U86'))
  GROUP BY EinzTeil.ID, ArtGroe.ArtikelID, EinzTeil.ArtGroeID, EinzTeil.Status, EinzTeil.RechPoID, EinzTeil.VsaID, EinzTeil.Code, EinzTeil.LastScanTime, EinzTeil.Erstwoche, EinzTeil.LastActionsID, fRW.BasisAfa, fRW.RestwertInfo

  UNION ALL

  SELECT N'TEILE' AS TableName, ArtGroe.ArtikelID, Teile.ArtGroeID, Teile.Status, Teile.RechPoID, Teile.VsaID, Teile.Barcode, Teile.LastScanTime, Week.Woche AS Erstwoche, CAST(MAX(CAST(KdArti.Vertragsartikel AS int)) AS bit) AS Vertragsartikel, Teile.LastActionsID, fRW.BasisAfa, fRW.RestwertInfo, CAST(0 AS bit) AS SetTeil
  FROM Teile
  CROSS APPLY dbo.funcGetRestwert(Teile.ID, @curweek, 1) fRW
  JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN KdArti ON ArtGroe.ArtikelID = KdArti.ArtikelID AND KdArti.KundenID = Vsa.KundenID
  JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
  WHERE ArtGroe.ArtikelID IN (SELECT ID FROM Artikel WHERE ArtikelNr IN (N'U82', N'U83', N'U84', N'U86'))
  AND Vsa.KundenID = (SELECT ID FROM kunden WHERE KdNr = 31200)
  GROUP BY Teile.ID, ArtGroe.ArtikelID, Teile.ArtGroeID, Teile.Status, Teile.RechPoID, Teile.VsaID, Teile.Barcode, Teile.LastScanTime, Week.Woche, Teile.LastActionsID, fRW.BasisAfa, fRW.RestwertInfo
) AS Schwundteile
JOIN Vsa ON Schwundteile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Schwundteile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON Schwundteile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Actions ON Schwundteile.LastActionsID = Actions.ID
LEFT JOIN PoolteilStatus ON PoolteilStatus.Status = Schwundteile.Status AND Schwundteile.TableName = N'EINZTEIL'
LEFT JOIN Teilestatus ON Teilestatus.Status = Schwundteile.Status AND Schwundteile.TableName = N'TEILE'
WHERE Schwundteile.RechPoID < 0
  AND Kunden.KdNr != 100151
  --AND Schwundteile.LastScanTime < $1$
  --AND Bereich.ID IN ($2$)
  --AND Kunden.ID = $ID$;
  AND Artikel.ArtikelNr IN (N'U82', N'U83', N'U84', N'U86')
  AND (PoolteilStatus.Status != N'Z' OR Teilestatus.Status BETWEEN N'K' AND N'X');