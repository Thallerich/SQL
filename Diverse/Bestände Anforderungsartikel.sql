SELECT Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Bestand AS Vertragsbestand, VsaAnf.BestandIst, VsaAnf.Durchschnitt, VsaAnf.LetzteLieferung
FROM VsaAnf, Vsa, Kunden, KdArti, ViewArtikel Artikel
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.ID = $KUNDENID$
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.LanguageID = $MAINLANGUAGEID$
  AND VsaAnf.Status = 'A'
ORDER BY VsaNr, ArtikelNr;


-- Report-Datei BestVsaAnf.rtm, 6,3 alle Ränder