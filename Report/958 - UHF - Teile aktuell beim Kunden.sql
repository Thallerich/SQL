SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, OPTeile.Code AS Chipcode, [Status].StatusBez$LAN$ AS [Status des Teils], REPLACE(Actions.ActionsBez$LAN$, N'OP ', N'') AS [Letzte Aktion], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, OPTeile.LastScanTime AS [Letzter Scan-Zeitpunkt], OPTeile.LastScanToKunde AS [Letzter Auslese-Zeitpunkt], CAST(IIF(OPTeile.RechPoID > 0 AND [Status].[Status] = N'W', 1, 0) AS bit) AS [Teil bereits Schwundverrechnet?]
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND Tabelle = N'OPTEILE'
WHERE (
    (Kunden.ID = $ID$ AND $1$ < 0)
    OR
    (Kunden.HoldingID = $1$ AND $1$ <> 0)
  )
  AND Bereich.ID IN ($2$)
  AND (
    (OPTeile.Status IN (N'Q', N'W') AND OPTeile.LastActionsID IN (102, 116) AND $3$ = 1)
    OR
    (OPTeile.Status = N'Q' AND OPTeile.LastActionsID = 102 AND $3$ = 0)
  );