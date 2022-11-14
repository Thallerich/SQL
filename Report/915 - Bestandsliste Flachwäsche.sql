DROP TABLE IF EXISTS #Bestandsliste915;

SELECT (
  SELECT TOP 1 Standort.Bez
  FROM StandBer, Standort
  WHERE StandBer.ProduktionID = Standort.ID
    AND StandBer.StandKonID IN ($1$) 
    AND StandBer.BereichID = 102
) AS Produktion, Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS BestandProduktion, SUM(LsPo.Menge) AS Liefermenge, COUNT(DISTINCT DATEPART(week, LsKo.Datum)) AS Lieferwochen, SUM(IIF(DATEPART(weekday, LsKo.Datum) = 2, LsPo.Menge, 0)) AS LMMontag, COUNT(DISTINCT IIF(DATEPART(weekday, LsKo.Datum) = 2, LsKo.Datum, CONVERT(date, NULL))) AS LTMontag, SUM(IIF(DATEPART(weekday, LsKo.Datum) = 3, LsPo.Menge, 0)) AS LMDienstag, COUNT(DISTINCT IIF(DATEPART(weekday, LsKo.Datum) = 3, LsKo.Datum, CONVERT(date, NULL))) AS LTDienstag, SUM(IIF(DATEPART(weekday, LsKo.Datum) = 4, LsPo.Menge, 0)) AS LMMittwoch, COUNT(DISTINCT IIF(DATEPART(weekday, LsKo.Datum) = 4, LsKo.Datum, CONVERT(date, NULL))) AS LTMittwoch, SUM(IIF(DATEPART(weekday, LsKo.Datum) = 5, LsPo.Menge, 0)) AS LMDonnerstag, COUNT(DISTINCT IIF(DATEPART(weekday, LsKo.Datum) = 5, LsKo.Datum, CONVERT(date, NULL))) AS LTDonnerstag, SUM(IIF(DATEPART(weekday, LsKo.Datum) = 6, LsPo.Menge, 0)) AS LMFreitag, COUNT(DISTINCT IIF(DATEPART(weekday, LsKo.Datum) = 6, LsKo.Datum, CONVERT(date, NULL))) AS LTFreitag, SUM(IIF(DATEPART(weekday, LsKo.Datum) = 7, LsPo.Menge, 0)) AS LMSamstag, COUNT(DISTINCT IIF(DATEPART(weekday, LsKo.Datum) = 7, LsKo.Datum, CONVERT(date, NULL))) AS LTSamstag
INTO #Bestandsliste915
FROM LsPo, LsKo, Vsa, KdArti, Artikel
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Vsa.StandKonID IN ($1$)
  AND DATEDIFF(day, GETDATE(), LsKo.Datum) <= 30
  --AND GETDATE() - LsKo.Datum <= 30  --Lieferscheine der letzten 30 Tage
  AND LsPo.Menge > 0 --Reklamationen (Liefermenge negativ) ignorieren
  AND Artikel.ID > 0  -- unbekannten Artikel ignorieren
  AND Artikel.EAN IS NOT NULL  -- nur UHF-Chip-Artikel
  --AND Artikel.BereichID <> 104 -- keine Eigenwäsche--
GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$;

INSERT INTO #Bestandsliste915
SELECT (
  SELECT TOP 1 Standort.Bez
  FROM StandBer, Standort
  WHERE StandBer.ProduktionID = Standort.ID
    AND StandBer.StandKonID IN ($1$) 
    AND StandBer.BereichID = 102
) AS Produktion, Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS BestandProduktion, 0 AS Liefermenge, 0 AS Lieferwochen, 0 AS LMMontag, 0 AS LTMontag, 0 AS LMDienstag, 0 AS LTDienstag, 0 AS LMMittwoch, 0 AS LTMittwoch, 0 AS LMDonnerstag, 0 AS LTDonnerstag, 0 AS LMFreitag, 0 AS LTFreitag, 0 AS LMSamstag, 0 AS LTSamstag
FROM EinzTeil, ZielNr, Artikel
WHERE EinzTeil.ZielNrID = ZielNr.ID
  AND EinzTeil.ArtikelID = Artikel.ID
  AND ZielNr.GeraeteNr IS NOT NULL
  AND ZielNr.ProduktionsID IN (SELECT StandBer.ProduktionID FROM StandBer WHERE StandBer.StandKonID IN ($1$) AND StandBer.BereichID = 102)
  AND EinzTeil.Status IN (N'A', N'Q')  -- Erstellte und aktive Teile
  AND EinzTeil.LastActionsID <> 102  -- zuletzt nicht ausgelesen, also nicht beim Kunden
  AND Artikel.ID > 0 -- unbekannten Artikel ignorieren
  AND Artikel.EAN IS NOT NULL --nur UHF-Chip-Artikel
  AND Artikel.BereichID <> 104 --keine Eigenwäsche
  AND Artikel.ID NOT IN (SELECT ArtikelID FROM #Bestandsliste915)
GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$;

UPDATE Bestandsliste SET BestandProduktion = x.Bestand
FROM #Bestandsliste915 Bestandsliste, (
  SELECT Artikel.ID AS ArtikelID, COUNT(EinzTeil.ID) AS Bestand
  FROM EinzTeil, ZielNr, Artikel
  WHERE EinzTeil.ZielNrID = ZielNr.ID
    AND EinzTeil.ArtikelID = Artikel.ID
    AND ZielNr.GeraeteNr IS NOT NULL
    AND ZielNr.ProduktionsID IN (SELECT StandBer.ProduktionID FROM StandBer WHERE StandBer.StandKonID IN ($1$) AND StandBer.BereichID = 102)
    AND EinzTeil.Status IN (N'A', N'Q')
    AND EinzTeil.LastActionsID <> 102
    AND Artikel.ID > 0
  GROUP BY Artikel.ID
) x
WHERE x.ArtikelID = Bestandsliste.ArtikelID;

SELECT Bestandsliste.Produktion, Bestandsliste.ArtikelNr, Bestandsliste.EAN, Bestandsliste.Artikelbezeichnung, Bestandsliste.BestandProduktion, Bestandsliste.Liefermenge, Bestandsliste.Lieferwochen, ROUND(IIF(Bestandsliste.Lieferwochen = 0, 0, Bestandsliste.Liefermenge / Bestandsliste.Lieferwochen), 0) AS [Durchschnitt LM wöchentlich], Bestandsliste.LMMontag, Bestandsliste.LTMontag, ROUND(IIF(Bestandsliste.LTMontag = 0, 0, Bestandsliste.LMMontag / Bestandsliste.LTMontag), 0) AS [Durchschnitt LM Montag], Bestandsliste.LMDienstag, Bestandsliste.LTDienstag, ROUND(IIF(Bestandsliste.LTDienstag = 0, 0, Bestandsliste.LMDienstag / Bestandsliste.LTDienstag), 0) AS [Durchschnitt LM Dienstag], Bestandsliste.LMMittwoch, Bestandsliste.LTMittwoch, ROUND(IIF(Bestandsliste.LTMittwoch = 0, 0, Bestandsliste.LMMittwoch / Bestandsliste.LTMittwoch), 0) AS [Durchschnitt LM Mittwoch], Bestandsliste.LMDonnerstag, Bestandsliste.LTDonnerstag, ROUND(IIF(Bestandsliste.LTDonnerstag = 0, 0, Bestandsliste.LMDonnerstag / Bestandsliste.LTDonnerstag), 0) AS [Durchschnitt LM Donnerstag], Bestandsliste.LMFreitag, Bestandsliste.LTFreitag, ROUND(IIF(Bestandsliste.LTFreitag = 0, 0, Bestandsliste.LMFreitag / Bestandsliste.LTFreitag), 0) AS [Durchschnitt LM Freitag], Bestandsliste.LMSamstag, Bestandsliste.LTSamstag, ROUND(IIF(Bestandsliste.LTSamstag = 0, 0, Bestandsliste.LMSamstag / Bestandsliste.LTSamstag), 0) AS [Durchschnitt LM Samstag]
FROM #Bestandsliste915 AS Bestandsliste
ORDER BY Bestandsliste.Artikelbezeichnung;