DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Inventurscan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.ActionsID = 120
  GROUP BY OPScans.OPTeileID
),
PoolteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'OPTEILE'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Schwundteile.Code AS Chipcode, PoolteilStatus.StatusBez AS [aktueller Status des Teils], Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Schwundteile.Vertragsartikel, Schwundteile.BasisAfa AS Basisrestwert, Schwundteile.RestwertInfo AS Restwert, CAST(Schwundteile.LastScanTime AS date) AS [letzter Scan], Actions.ActionsBez AS [letzte Aktion], CAST(Inventurscan.Zeitpunkt AS date) AS [zuletzt inventiert], DATEDIFF(day, Schwundteile.LastScanTime, GETDATE()) AS [Tage ohne Bewegung], Schwundteile.Erstwoche AS [Erster Einsatz], Schwundteile.SetTeil AS [ist Set-Inhalt?], CAST(IIF(Schwundteile.RechPoID = -2, 1, 0) AS bit) AS [ohne Berrechnung?]
FROM (
  SELECT OPTeile.ID AS OPTeileID, ArtGroe.ArtikelID, OPTeile.ArtGroeID, OPTeile.Status, OPTeile.RechPoID, OPTeile.VsaID, OPTeile.Code, OPTeile.LastScanTime, OPTeile.Erstwoche, OPTeile.LastErsatzFuerKdArtiID, CAST(MAX(CAST(KdArti.Vertragsartikel AS int)) AS bit) AS Vertragsartikel, OPTeile.LastActionsID, fRW.BasisAfa, fRW.RestwertInfo, CAST(0 AS bit) AS SetTeil
  FROM Opteile
  CROSS APPLY dbo.funcGetRestWertOP(OpTeile.ID, @curweek, 1) fRW
  JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN KdArti ON ArtGroe.ArtikelID = KdArti.ArtikelID AND KdArti.KundenID = Vsa.KundenID
  WHERE Vsa.KundenID = $ID$
  GROUP BY OPTeile.ID, ArtGroe.ArtikelID, OPTeile.ArtGroeID, OPTeile.Status, OPTeile.RechPoID, OPTeile.VsaID, OPTeile.Code, OPTeile.LastScanTime, OPTeile.Erstwoche, OPTeile.LastActionsID, OPTeile.LastErsatzFuerKdArtiID, fRW.BasisAfa, fRW.RestwertInfo
  
  UNION
  
  SELECT Opteile.ID AS OPTeileID, OPTeile.ArtikelID, OPTeile.ArtGroeID, OPTeile.Status, OPTeile.RechPoID, OPTeile.VsaID, OPTeile.Code, OPTeile.LastScanTime, OPTeile.Erstwoche, OPTeile.LastErsatzFuerKdArtiID, CAST(0 AS bit) AS VertragsArtikel, OPTeile.LastActionsID, CAST(0 AS money) AS BasisAfa, CAST(0 AS money) AS RestwertInfo, CAST(1 AS bit) AS SetTeil
  FROM OPTeile
  JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
  JOIN OPEtiPo ON OPEtiPo.OPTeileID = OPTeile.ID
  JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID AND OPEtiKo.VsaID = OPTeile.VsaID
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
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
LEFT JOIN Inventurscan ON Inventurscan.OPTeileID = Schwundteile.OPTeileID
JOIN PoolteilStatus ON PoolteilStatus.Status = Schwundteile.Status
WHERE (($3$ = 1 AND Schwundteile.LastActionsID IN (102, 120, 136, 116)) OR ($3$ = 0 AND Schwundteile.LastActionsID IN (102, 120, 136)))  --schwundgebuchte Teile anzeigen, falls Parameter aktiviert
  AND Schwundteile.RechPoID < 0
  AND Schwundteile.LastScanTime < $1$
  AND Bereich.ID IN ($2$)
  AND Kunden.ID = $ID$;