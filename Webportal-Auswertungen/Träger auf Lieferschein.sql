SELECT LsKo.LsNr, LsKo.Datum, Traeger.Traeger AS Träger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(Scans.ID) AS Menge
FROM Scans
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE LsKo.LsNr = $lsnr
GROUP BY LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname
ORDER BY Träger, Artikelbezeichnung;