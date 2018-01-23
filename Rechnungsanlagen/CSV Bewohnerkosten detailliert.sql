SELECT Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, Traeger.Traeger AS Bewohnernummer, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr AS Zimmer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, TraeRech.Menge, TraeRech.Preis, ROUND(CONVERT(money, TraeRech.Menge) * TraeRech.Preis, 2) AS Netto, ROUND((CONVERT(money, TraeRech.Menge) * TraeRech.Preis) / 100 * MwSt.MwStSatz, 2) AS MwSt, ROUND(CONVERT(money, TraeRech.Menge) * TraeRech.Preis * (1 + MwSt.MwStSatz / 100), 2) AS Brutto
FROM RechPo, TraeRech, KdArti, KdBer, Artikel , Abteil, MwSt, Traeger
LEFT JOIN BewAbr ON BewAbr.ID = Traeger.BewAbrID
WHERE RechPo.RechKoID = $RECHKOID$
  AND Abteil.ID = RechPo.AbteilID
  AND TraeRech.RechPoID = RechPo.ID
  AND Traeger.ID = TraeRech.TraegerID
  AND TraeRech.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND TraeRech.Preis > 0
  AND RechPo.MwStID = MwSt.ID
ORDER BY Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr;