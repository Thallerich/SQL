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
SELECT Produktion.SuchCode AS Produktion, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status des Trägers], EinzHist.Barcode, Teilestatus.StatusBez AS [Status des Teils], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Prod.EinDat AS [Abhol-Datum], Prod.AusDat AS [Rückliefer-Datum], ZielNr.ZielNrBez$LAN$ AS [letzter Ort], Actions.ActionsBez$LAN$ AS [letzte Aktion]
FROM Prod
JOIN EinzHist ON Prod.EinzHistID = EinzHist.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN ZielNr ON EinzHist.LastZielNrID = ZielNr.ID
JOIN Actions ON EinzHist.LastActionsID = Actions.ID
JOIN Standort AS Produktion ON Prod.ProduktionID = Produktion.ID
WHERE CAST(GETDATE() AS date) >= Prod.AusDat
  AND Produktion.ID IN ($1$)
  AND Bereich.ID IN ($2$)
  AND EinzHist.Status BETWEEN N'M' AND N'S'
  AND Vsa.Status != N'I'
  AND Kunden.Status != N'I'
  AND Artikel.Status != N'B';