SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, EinzHist.Barcode, EinzHist.PatchDatum, EinzTeil.AltenheimModus
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
WHERE EinzHist.PatchDatum = N'2023-06-12'
  AND (
    (EinzTeil.AltenheimModus = 1 AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'MATT'))
    OR
    (EinzTeil.AltenheimModus = 0 AND EinzTeil.LagerArtID IN (SELECT ID FROM Lagerart WHERE Lagerart.LagerID = (SELECT ID FROM Standort WHERE SuchCode = N'MATT')))
  )