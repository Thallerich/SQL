SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, OPTeile.Code AS Chipcode, REPLACE(Actions.ActionsBez$LAN$, N'OP ', N'') AS [Letzte Aktion], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, OPTeile.LastScanTime AS [Letzter Scan-Zeitpunkt], OPTeile.LastScanToKunde AS [Letzter Auslese-Zeitpunkt]
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
WHERE Kunden.ID = $ID$
  AND Bereich.ID = $2$
  AND OPTeile.Status = N'Q' -- nur aktive Teile
  AND OPTeile.LastActionsID = 102 -- nur Teile, die zuletzt ausgelesen und somit beim Kunden sind
;