WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Produktion.SuchCode AS Produktion, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status des Trägers], Teile.Barcode, Teilestatus.StatusBez AS [Status des Teils], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Prod.EinDat AS [Abhol-Datum], Prod.AusDat AS [Rückliefer-Datum], ZielNr.ZielNrBez$LAN$ AS [letzter Ort], Actions.ActionsBez$LAN$ AS [letzte Aktion]
FROM Prod
JOIN Teile ON Prod.TeileID = Teile.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN ZielNr ON Teile.LastZielNrID = ZielNr.ID
JOIN Actions ON Teile.LastActionsID = Actions.ID
JOIN Standort AS Produktion ON Prod.ProduktionID = Produktion.ID
WHERE CAST(GETDATE() AS date) >= Prod.AusDat
  AND Produktion.ID IN ($1$)
  AND Bereich.ID IN ($2$)
  AND Teile.Status BETWEEN N'M' AND N'S'
  AND Vsa.Status != N'I'
  AND Kunden.Status != N'I'
  AND Artikel.Status != N'B';