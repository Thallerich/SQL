SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzHist.Barcode, Scans.[DateTime] AS [Patch-Zeitpunkt], EinzHist.PatchDatum AS [erstmals gepatcht am]
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
WHERE Scans.[DateTime] BETWEEN $1$ AND DATEADD(day, 1, $1$)
  AND Scans.ActionsID = 23
  AND EinzTeil.AltenheimModus = 1
  AND StandBer.ProduktionID = $2$;