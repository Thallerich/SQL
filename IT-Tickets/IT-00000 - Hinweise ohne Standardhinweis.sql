WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
),
Vsastatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSA'
),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Teile.Barcode, Teilestatus.StatusBez AS [Status Teil], Teile.LastScanTime AS [Zeitpunkt letzter Scan], ZielNr.ZielNrBez AS [letzter Scan-Ort], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Vsastatus.StatusBez AS [Status Vsa], Traeger.Traeger AS TrägerNr, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS [Status Träger], StandKon.StandKonBez AS [Standort-Konfiguration], Produktion.SuchCode AS Produktion, SdcDev.Bez AS [Sortieranlage], Hinweis.Hinweis, Hinweis.Aktiv
FROM Hinweis
JOIN Teile ON Hinweis.TeileID = Teile.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Vsastatus ON Vsa.[Status] = Vsastatus.[Status]
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN ZielNr ON Teile.LastZielNrID = ZielNr.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN KdArti ON Teile.KdArtiID = kdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = KdBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
LEFT JOIN StBerSDC ON StBerSDC.StandBerID = StandBer.ID
LEFT JOIN SdcDev ON StBerSDC.SdcDevID = SdcDev.ID
WHERE Teile.Status BETWEEN N'K' AND N'W'
  AND Teile.Einzug IS NULL
  AND Teile.AltenheimModus = 0
  AND Hinweis.Aktiv = 1
  AND Hinweis.HinwTextID < 0
  AND Hinweis.Hinweis NOT LIKE N'<_>%';