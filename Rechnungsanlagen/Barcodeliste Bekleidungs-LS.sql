SELECT Kunden.KdNr, Vsa.VsaNr, Vsa.SuchCode AS VsaSuchCode, Vsa.Name1, Vsa.Name2, Vsa.Name3, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Vsa.MemoLS, LsKo.LsNr, LsKo.Datum, Touren.Bez AS Tour, Touren.Tour AS TourKurz, TRIM(Mitarbei.Nachname) + IIF(Mitarbei.Vorname <> '', ', ' + TRIM(Mitarbei.Vorname), '') AS Fahrer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, KdArti.Variante, ArtGroe.Groesse, Abteil.Bez AS Kostenstelle, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, EinzHist.Barcode, Scans.[DateTime] AS AusleseZeitpunkt, Traeger.ID AS TraegerID, Abteil.ID AS KostenstellenID
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Mitarbei ON Fahrt.MitarbeiID = Mitarbei.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
WHERE RechPo.RechKoID = $RECHKOID$
  AND EinzTeil.AltenheimModus = 0 --keine Bewohnerwäsche
  AND Scans.EinzHistID > 0
ORDER BY Kunden.KdNr, Vsa.VsaNr, LsKo.LsNr, KostenstellenID, Traeger.Nachname, Artikel.ArtikelNr;