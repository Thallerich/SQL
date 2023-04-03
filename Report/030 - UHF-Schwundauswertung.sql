DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Inventurscan AS (
  SELECT Scans.EinzTeilID, MAX(Scans.[DateTime]) AS Zeitpunkt
  FROM Scans
  WHERE Scans.ActionsID = 120
  GROUP BY Scans.EinzTeilID
),
PoolteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZTEIL'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Schwundteile.Code AS Chipcode, PoolteilStatus.StatusBez AS [aktueller Status des Teils], Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Schwundteile.Vertragsartikel, Schwundteile.BasisAfa AS Basisrestwert, Schwundteile.RestwertInfo AS Restwert, CAST(Schwundteile.LastScanTime AS date) AS [letzter Scan], Actions.ActionsBez AS [letzte Aktion], CAST(Inventurscan.Zeitpunkt AS date) AS [zuletzt inventiert], DATEDIFF(day, Schwundteile.LastScanTime, GETDATE()) AS [Tage ohne Bewegung], Schwundteile.Erstwoche AS [Erster Einsatz], Schwundteile.SetTeil AS [ist Set-Inhalt?], CAST(IIF(Schwundteile.RechPoID = -2, 1, 0) AS bit) AS [ohne Berrechnung?]
FROM (
  SELECT EinzTeil.ID AS EinzTeilID, ArtGroe.ArtikelID, EinzTeil.ArtGroeID, EinzTeil.Status, EinzTeil.RechPoID, EinzTeil.VsaID, EinzTeil.Code, EinzTeil.LastScanTime, EinzTeil.Erstwoche, EinzTeil.LastErsatzFuerKdArtiID, CAST(MAX(CAST(KdArti.Vertragsartikel AS int)) AS bit) AS Vertragsartikel, EinzTeil.LastActionsID, fRW.BasisAfa, fRW.RestwertInfo, CAST(0 AS bit) AS SetTeil
  FROM EinzTeil
  CROSS APPLY dbo.funcGetRestWertOP(EinzTeil.ID, @curweek, 1) fRW
  JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  JOIN KdArti ON ArtGroe.ArtikelID = KdArti.ArtikelID AND KdArti.KundenID = Vsa.KundenID
  WHERE Vsa.KundenID = $ID$
  GROUP BY EinzTeil.ID, ArtGroe.ArtikelID, EinzTeil.ArtGroeID, EinzTeil.Status, EinzTeil.RechPoID, EinzTeil.VsaID, EinzTeil.Code, EinzTeil.LastScanTime, EinzTeil.Erstwoche, EinzTeil.LastActionsID, EinzTeil.LastErsatzFuerKdArtiID, fRW.BasisAfa, fRW.RestwertInfo
  
  UNION
  
  SELECT EinzTeil.ID AS EinzTeilID, EinzTeil.ArtikelID, EinzTeil.ArtGroeID, EinzTeil.Status, EinzTeil.RechPoID, EinzTeil.VsaID, EinzTeil.Code, EinzTeil.LastScanTime, EinzTeil.Erstwoche, EinzTeil.LastErsatzFuerKdArtiID, CAST(0 AS bit) AS VertragsArtikel, EinzTeil.LastActionsID, CAST(0 AS money) AS BasisAfa, CAST(0 AS money) AS RestwertInfo, CAST(1 AS bit) AS SetTeil
  FROM EinzTeil
  JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
  JOIN OPEtiPo ON OPEtiPo.EinzTeilID = EinzTeil.ID
  JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID AND OPEtiKo.VsaID = EinzTeil.VsaID
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
  WHERE Vsa.KundenID = $ID$
    AND OPEtiKo.Status IN (N'R', N'U')
    AND NOT EXISTS (
      SELECT KdArti.ID
      FROM KdArti
      WHERE KdArti.KundenID = Vsa.KundenID
        AND KdArti.ArtikelID = ArtGroe.ArtikelID
    )
) AS Schwundteile
JOIN Vsa ON Schwundteile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Schwundteile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON Schwundteile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Actions ON Schwundteile.LastActionsID = Actions.ID
LEFT JOIN Inventurscan ON Inventurscan.EinzTeilID = Schwundteile.EinzTeilID
JOIN PoolteilStatus ON PoolteilStatus.Status = Schwundteile.Status
WHERE (($3$ = 1 AND Schwundteile.LastActionsID IN (2, 102, 120, 129, 130, 136, 154, 116)) OR ($3$ = 0 AND Schwundteile.LastActionsID IN (2, 102, 120, 129, 130, 136, 154)))  --schwundgebuchte Teile anzeigen, falls Parameter aktiviert
  AND Schwundteile.RechPoID < 0
  AND Schwundteile.LastScanTime < $1$
  AND Bereich.ID IN ($2$)
  AND Kunden.ID = $ID$;