-- Pipeline: Reparaturen

SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, RepDaten.ArtikelNr, RepDaten.Artikelbezeichnung, RepDaten.Barcode, RepType.ArtikelBez$LAN$ AS Reparaturgrund, RepDaten.LastRepDate AS [Letzte Reparatur], RepDaten.RepAnz AS [Anzahl Reparaturen], RepDaten.Indienst, Standort.Bez AS Produktion
FROM Traeger, Vsa, Kunden, StandKon, StandBer, Standort, Artikel AS RepType, (
  SELECT Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID
  FROM Teile, TeilSoFa, KdArti, Artikel, KdBer
  WHERE TeilSoFa.TeileID = Teile.ID
    AND Teile.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KdBerID = KdBer.ID
    AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $1$ AND $2$
  GROUP BY Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID
  AND StandBer.BereichID = RepDaten.BereichID
  AND StandBer.ProduktionID = Standort.ID
  AND RepDaten.RepTypeID = RepType.ID
  AND Standort.ID IN ($3$)
  AND RepType.ArtiTypeID = 5 --nur Reparaturen
ORDER BY KdNr, VsaNr, Traeger;

-- Pipeline: Reparaturen_Summen

SELECT RepType.ArtikelBez$LAN$ AS Reparaturgrund, SUM(RepDaten.RepAnz) AS [Anzahl Reparaturen], Standort.Bez AS Produktion
FROM Traeger, Vsa, Kunden, StandKon, StandBer, Standort, Artikel AS RepType, (
  SELECT Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID
  FROM Teile, TeilSoFa, KdArti, Artikel, KdBer
  WHERE TeilSoFa.TeileID = Teile.ID
    AND Teile.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KdBerID = KdBer.ID
    AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $1$ AND $2$
  GROUP BY Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID
  AND StandBer.BereichID = RepDaten.BereichID
  AND StandBer.ProduktionID = Standort.ID
  AND RepDaten.RepTypeID = RepType.ID
  AND Standort.ID IN ($3$)
  AND RepType.ArtiTypeID = 5 --nur Reparaturen
GROUP BY RepType.ArtikelBez$LAN$, Standort.Bez

UNION ALL

SELECT N'_Reparaturen Gesamt' AS Reparaturgrund, SUM(RepDaten.RepAnz) AS [Anzahl Reparaturen], N'(alle ausgewählten Standorte)' AS Produktion
FROM Traeger, Vsa, Kunden, StandKon, StandBer, Standort, Artikel AS RepType, (
  SELECT Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID
  FROM Teile, TeilSoFa, KdArti, Artikel, KdBer
  WHERE TeilSoFa.TeileID = Teile.ID
    AND Teile.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KdBerID = KdBer.ID
    AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $1$ AND $2$
  GROUP BY Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID
  AND StandBer.BereichID = RepDaten.BereichID
  AND StandBer.ProduktionID = Standort.ID
  AND RepDaten.RepTypeID = RepType.ID
  AND Standort.ID IN ($3$)
  AND RepType.ArtiTypeID = 5 -- nur Reparaturen
ORDER BY Reparaturgrund, Produktion;