WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
)
SELECT Kunden.Kdnr, Kunden.Suchcode as Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS Trägerstatus, Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Teile.Anlage_ AS [Teil angelegt am], EntnKo.Anlage_ AS [Entnahmeliste angelegt am], EntnKo.DruckDatum AS [Druckdatum Entnahmeliste], [Entnahme-Datum] = (
  SELECT MAX(Scans.[DateTime])
  FROM Scans
  WHERE Scans.TeileID = Teile.ID
    AND Scans.ActionsID = 57
), EntnKo.PatchDatum AS [Patchdatum Entnahmeliste]
FROM Teile
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
LEFT OUTER JOIN EntnPo ON Teile.EntnPoID = EntnPo.ID AND Teile.EntnPoID > 0
LEFT OUTER JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
WHERE Teile.Anlage_ > N'2019-04-01 00:00:00'
  AND Artikel.BereichID = 100
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND Traeger.Status != N'I'
  AND Teilestatus.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$)
  AND Kunden.StandortID IN ($3$)
ORDER BY [Entnahmeliste angelegt am];