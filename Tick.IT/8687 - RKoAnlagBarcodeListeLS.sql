SELECT Kunden.KdNr, Vsa.VsaNr, Vsa.SuchCode AS VsaSuchCode, Vsa.Name1, Vsa.Name2, Vsa.Name3, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Vsa.MemoLS, LsKo.LsNr, LsKo.Datum, Touren.Bez AS Tour, Touren.Tour AS TourKurz, TRIM(Mitarbei.Nachname) + IIF(Mitarbei.Vorname <> '', ', ' + TRIM(Mitarbei.Vorname), '') AS Fahrer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, KdArti.Variante, ArtGroe.Groesse, Abteil.Bez AS Kostenstelle, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Teile.Barcode, Scans.DateTime AS AusleseZeitpunkt, Traeger.ID AS TraegerID, Abteil.ID AS KostenstellenID
FROM Scans, Teile, Traeger, LsPo, LsKo, KdArti, Artikel, Vsa, Kunden, Fahrt, Touren, Mitarbei, RechPo, ArtGroe, Abteil
WHERE Scans.TeileID = Teile.ID
  AND Teile.TraegerID = Traeger.ID
  AND Scans.LsPoID = LsPo.ID
  AND LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.RechPoID = RechPo.ID
  AND RechPo.RechKoID = $RECHKOID$
  AND LsKo.FahrtID = Fahrt.ID
  AND Fahrt.TourenID = Touren.ID
  AND Fahrt.MitarbeiID = Mitarbei.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND LsPo.AbteilID = Abteil.ID
  AND Teile.AltenheimModus = 0 --keine Bewohnerwäsche
ORDER BY Kunden.KdNr, Vsa.VsaNr, LsKo.LsNr, KostenstellenID, Traeger.Nachname, Artikel.ArtikelNr;