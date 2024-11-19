WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, Standort.SuchCode AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, Teilestatus.StatusBez AS [Status Teil], EinzHist.AbmeldDat AS [Abmelde-Datum], EinzHist.AusdienstDat AS [Außerdienststellungs-Datum], __EinzHistNachfolgeEinzHist.AustauschScanDateTime AS [Zeitpunkt Austausch-Scan], __EinzHistNachfolgeEinzHist.StopAuftragZeitpunkt AS [Zeitpunkt Teil-Abmeldung]
FROM __EinzHistNachfolgeEinzHist
JOIN EinzHist ON __EinzHistNachfolgeEinzHist.AltEinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
WHERE __EinzHistNachfolgeEinzHist.NachfolgeEinzHistID IS NULL
  AND EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.[Status] = N'S';

GO