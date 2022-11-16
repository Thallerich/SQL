/* Pipeline Reparaturen */

DECLARE @ShowUser bit = $3$;

IF @ShowUser = 0
BEGIN
  SELECT KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode, Hauptstandort.Bez AS Hauptstandort, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, RepDaten.ArtikelNr, RepDaten.Artikelbezeichnung, RepDaten.Barcode, RepType.ArtikelBez$LAN$ AS Reparaturgrund, RepDaten.LastRepDate AS [Letzte Reparatur], RepDaten.RepAnz AS [Anzahl Reparaturen], RepDaten.Indienst, Standort.Bez AS Produktion
  FROM Traeger, Vsa, Kunden, KdGf, StandKon, StandBer, Standort, Standort AS Hauptstandort, Artikel AS RepType, (
    SELECT EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID
    FROM EinzHist, TeilSoFa, KdArti, Artikel, KdBer
    WHERE TeilSoFa.EinzHistID = EinzHist.ID
      AND EinzHist.KdArtiID = KdArti.ID
      AND KdArti.ArtikelID = Artikel.ID
      AND KdArti.KdBerID = KdBer.ID
      AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $STARTDATE$ AND $ENDDATE$
    GROUP BY EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID
  ) AS RepDaten
  WHERE RepDaten.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdGfID = KdGf.ID
    AND Kunden.StandortID = Hauptstandort.ID
    AND Vsa.StandKonID = StandKon.ID
    AND StandBer.StandKonID = StandKon.ID
    AND StandBer.BereichID = RepDaten.BereichID
    AND StandBer.ProduktionID = Standort.ID
    AND RepDaten.RepTypeID = RepType.ID
    AND Standort.ID IN ($2$)
    AND RepType.ArtiTypeID = 5 --nur Reparaturen
  ORDER BY KdNr, VsaNr, Traeger;
END
ELSE
BEGIN
  SELECT KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode, Hauptstandort.Bez AS Hauptstandort, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, RepDaten.ArtikelNr, RepDaten.Artikelbezeichnung, RepDaten.Barcode, RepType.ArtikelBez$LAN$ AS Reparaturgrund, RepDaten.LastRepDate AS [Letzte Reparatur], RepDaten.RepAnz AS [Anzahl Reparaturen], RepDaten.Indienst, Standort.Bez AS Produktion, Mitarbei.UserName AS [User], RepDaten.Zeitpunkt AS Erfassungszeit
  FROM Traeger, Vsa, Kunden, KdGf, StandKon, StandBer, Standort, Standort AS Hauptstandort, Artikel AS RepType, Mitarbei, (
    SELECT EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID, TeilSoFa.MitarbeiID, FORMAT(TeilSoFa.Zeitpunkt, N'dd.MM.yyyy HH:mm') AS Zeitpunkt
    FROM EinzHist, TeilSoFa, KdArti, Artikel, KdBer
    WHERE TeilSoFa.EinzHistID = EinzHist.ID
      AND EinzHist.KdArtiID = KdArti.ID
      AND KdArti.ArtikelID = Artikel.ID
      AND KdArti.KdBerID = KdBer.ID
      AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $STARTDATE$ AND $ENDDATE$
    GROUP BY EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID, TeilSoFa.MitarbeiID, FORMAT(TeilSoFa.Zeitpunkt, N'dd.MM.yyyy HH:mm')
  ) AS RepDaten
  WHERE RepDaten.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdGfID = KdGf.ID
    AND Kunden.StandortID = Hauptstandort.ID
    AND Vsa.StandKonID = StandKon.ID
    AND StandBer.StandKonID = StandKon.ID
    AND StandBer.BereichID = RepDaten.BereichID
    AND StandBer.ProduktionID = Standort.ID
    AND RepDaten.RepTypeID = RepType.ID
    AND RepDaten.MitarbeiID = Mitarbei.ID
    AND Standort.ID IN ($2$)
    AND RepType.ArtiTypeID = 5 --nur Reparaturen
  ORDER BY KdNr, VsaNr, Traeger;
END;

/* Pipeline ReparaturenSummen */

SELECT RepType.ArtikelBez$LAN$ AS Reparaturgrund, SUM(RepDaten.RepAnz) AS [Anzahl Reparaturen], Standort.Bez AS Produktion
FROM Traeger, Vsa, Kunden, StandKon, StandBer, Standort, Artikel AS RepType, (
  SELECT EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID
  FROM EinzHist, TeilSoFa, KdArti, Artikel, KdBer
  WHERE TeilSoFa.EinzHistID = EinzHist.ID
    AND EinzHist.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KdBerID = KdBer.ID
    AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $STARTDATE$ AND $ENDDATE$
  GROUP BY EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID
  AND StandBer.BereichID = RepDaten.BereichID
  AND StandBer.ProduktionID = Standort.ID
  AND RepDaten.RepTypeID = RepType.ID
  AND Standort.ID IN ($2$)
  AND RepType.ArtiTypeID = 5 --nur Reparaturen
GROUP BY RepType.ArtikelBez$LAN$, Standort.Bez

UNION ALL

SELECT N'_Reparaturen Gesamt' AS Reparaturgrund, SUM(RepDaten.RepAnz) AS [Anzahl Reparaturen], N'(alle ausgewählten Standorte)' AS Produktion
FROM Traeger, Vsa, Kunden, StandKon, StandBer, Standort, Artikel AS RepType, (
  SELECT EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID AS RepTypeID, CONVERT(date, MAX(TeilSoFa.Zeitpunkt)) AS LastRepDate, SUM(TeilSoFa.Menge) AS RepAnz, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdBer.BereichID
  FROM EinzHist, TeilSoFa, KdArti, Artikel, KdBer
  WHERE TeilSoFa.EinzHistID = EinzHist.ID
    AND EinzHist.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.KdBerID = KdBer.ID
    AND CONVERT(date, TeilSoFa.Zeitpunkt) BETWEEN $STARTDATE$ AND $ENDDATE$
  GROUP BY EinzHist.TraegerID, EinzHist.Barcode, EinzHist.Indienst, TeilSoFa.ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdBer.BereichID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID
  AND StandBer.BereichID = RepDaten.BereichID
  AND StandBer.ProduktionID = Standort.ID
  AND RepDaten.RepTypeID = RepType.ID
  AND Standort.ID IN ($2$)
  AND RepType.ArtiTypeID = 5 -- nur Reparaturen
ORDER BY Reparaturgrund, Produktion;