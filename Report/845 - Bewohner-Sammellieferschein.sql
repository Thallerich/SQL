SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.Land, Kunden.ID AS KundenID, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS VsaName, Traeger.Vorname, Traeger.Nachname, Traeger.Traeger, Traeger.PersNr, LsKo.Datum, Touren.Bez AS Tour, Touren.Tour AS TourKurz, MAX(TRIM(Mitarbei.Nachname) + IIF(Mitarbei.Vorname <> '', ', ' + TRIM(Mitarbei.Vorname), '')) AS FahrerName, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, SUM(IIF(KdArti.ArtikelID = 3714, 0, LsPo.Menge)) AS AnzahlTeile, SUM(IIF(KdArti.ArtikelID = 3714, LsPo.Menge, 0)) AS AnzahlPatches
FROM LsPo, Traeger, Vsa, Kunden, KdArti, Artikel, LsKo
LEFT OUTER JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
LEFT OUTER JOIN Touren ON Fahrt.TourenID = Touren.ID
LEFT OUTER JOIN Mitarbei ON Fahrt.MitarbeiID = Mitarbei.ID
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.TraegerID = Traeger.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum = $2$
  AND Kunden.ID = $1$
  AND KdArti.LSAusblenden = 0
  AND LsKo.TraegerID > 0
  AND LsPo.Menge <> 0
GROUP BY Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.Land, Kunden.ID, Vsa.ID, Vsa.VsaNr, Vsa.Bez, Traeger.Vorname, Traeger.Nachname, Traeger.Traeger, Traeger.PersNr, LsKo.Datum, Touren.Bez, Touren.Tour, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Vsa.VsaNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr;