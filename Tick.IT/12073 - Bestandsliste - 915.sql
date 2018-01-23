TRY
  DROP TABLE #Bestandsliste;
CATCH ALL END;

SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS BestandProduktion, SUM(LsPo.Menge) AS Liefermenge, COUNT(DISTINCT WEEK(LsKo.Datum)) AS Lieferwochen, SUM(IIF(DAYOFWEEK(LsKo.Datum) = 2, LsPo.Menge, 0)) AS LMMontag, COUNT(DISTINCT IIF(DAYOFWEEK(LsKo.Datum) = 2, LsKo.Datum, CONVERT(NULL, SQL_DATE))) AS LTMontag, SUM(IIF(DAYOFWEEK(LsKo.Datum) = 3, LsPo.Menge, 0)) AS LMDienstag, COUNT(DISTINCT IIF(DAYOFWEEK(LsKo.Datum) = 3, LsKo.Datum, CONVERT(NULL, SQL_DATE))) AS LTDienstag, SUM(IIF(DAYOFWEEK(LsKo.Datum) = 4, LsPo.Menge, 0)) AS LMMittwoch, COUNT(DISTINCT IIF(DAYOFWEEK(LsKo.Datum) = 4, LsKo.Datum, CONVERT(NULL, SQL_DATE))) AS LTMittwoch, SUM(IIF(DAYOFWEEK(LsKo.Datum) = 5, LsPo.Menge, 0)) AS LMDonnerstag, COUNT(DISTINCT IIF(DAYOFWEEK(LsKo.Datum) = 5, LsKo.Datum, CONVERT(NULL, SQL_DATE))) AS LTDonnerstag, SUM(IIF(DAYOFWEEK(LsKo.Datum) = 6, LsPo.Menge, 0)) AS LMFreitag, COUNT(DISTINCT IIF(DAYOFWEEK(LsKo.Datum) = 6, LsKo.Datum, CONVERT(NULL, SQL_DATE))) AS LTFreitag, SUM(IIF(DAYOFWEEK(LsKo.Datum) = 7, LsPo.Menge, 0)) AS LMSamstag, COUNT(DISTINCT IIF(DAYOFWEEK(LsKo.Datum) = 7, LsKo.Datum, CONVERT(NULL, SQL_DATE))) AS LTSamstag
INTO #Bestandsliste
FROM LsPo, LsKo, Vsa, KdArti, Artikel
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Vsa.StandKonID IN ($1$)
  AND CURDATE() - LsKo.Datum <= 30  --Lieferscheine der letzten 30 Tage
  AND LsPo.Menge > 0 --Reklamationen (Liefermenge negativ) ignorieren
  AND Artikel.ID > 0  -- unbekannten Artikel ignorieren
  AND Artikel.EAN IS NOT NULL  -- nur UHF-Chip-Artikel
  --AND Artikel.BereichID <> 104 -- keine Eigenwäsche--
GROUP BY ArtikelID, Artikel.ArtikelNr, Artikel.EAN, Artikelbezeichnung;

INSERT INTO #Bestandsliste
SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS BestandProduktion, 0 AS Liefermenge, 0 AS Lieferwochen, 0 AS LMMontag, 0 AS LTMontag, 0 AS LMDienstag, 0 AS LTDienstag, 0 AS LMMittwoch, 0 AS LTMittwoch, 0 AS LMDonnerstag, 0 AS LTDonnerstag, 0 AS LMFreitag, 0 AS LTFreitag, 0 AS LMSamstag, 0 AS LTSamstag
FROM OPTeile, ZielNr, Artikel
WHERE OPTeile.ZielNrID = ZielNr.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND ZielNr.GeraeteNr IS NOT NULL
  AND ZielNr.ProduktionsID IN (SELECT StandBer.ProduktionID FROM StandBer WHERE StandBer.StandKonID IN ($1$) AND StandBer.BereichID = 102)
  AND OPTeile.Status < 'R'  --Teile nicht beim Kunden
  AND Artikel.ID > 0 -- unbekannten Artikel ignorieren
  AND Artikel.EAN IS NOT NULL --nur UHF-Chip-Artikel
  AND Artikel.BereichID <> 104 --keine Eigenwäsche
  AND Artikel.ID NOT IN (SELECT ArtikelID FROM #Bestandsliste)
GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.EAN, Artikel.ArtikelBez$LAN$;

UPDATE Bestandsliste SET BestandProduktion = x.Bestand
FROM #Bestandsliste Bestandsliste, (
  SELECT Artikel.ID AS ArtikelID, COUNT(OPTeile.ID) AS Bestand
  FROM OPTeile, ZielNr, Artikel
  WHERE OPTeile.ZielNrID = ZielNr.ID
    AND OPTeile.ArtikelID = Artikel.ID
    AND ZielNr.GeraeteNr IS NOT NULL
    AND ZielNr.ProduktionsID IN (SELECT StandBer.ProduktionID FROM StandBer WHERE StandBer.StandKonID IN ($1$) AND StandBer.BereichID = 102)
    AND OPTeile.Status < 'R'  --Teile nicht beim Kunden
    AND Artikel.ID > 0 -- unbekannten Artikel ignorieren
  GROUP BY ArtikelID
) x
WHERE x.ArtikelID = Bestandsliste.ArtikelID;

SELECT Bestandsliste.ArtikelNr, Bestandsliste.EAN, Bestandsliste.Artikelbezeichnung, Bestandsliste.BestandProduktion, Bestandsliste.Liefermenge, Bestandsliste.Lieferwochen, ROUND(IIF(Bestandsliste.Lieferwochen = 0, 0, Bestandsliste.Liefermenge / Bestandsliste.Lieferwochen), 0) AS [Durchschnitt LM wöchentlich], Bestandsliste.LMMontag, Bestandsliste.LTMontag, ROUND(IIF(Bestandsliste.LTMontag = 0, 0, Bestandsliste.LMMontag / Bestandsliste.LTMontag), 0) AS [Durchschnitt LM Montag], Bestandsliste.LMDienstag, Bestandsliste.LTDienstag, ROUND(IIF(Bestandsliste.LTDienstag = 0, 0, Bestandsliste.LMDienstag / Bestandsliste.LTDienstag), 0) AS [Durchschnitt LM Dienstag], Bestandsliste.LMMittwoch, Bestandsliste.LTMittwoch, ROUND(IIF(Bestandsliste.LTMittwoch = 0, 0, Bestandsliste.LMMittwoch / Bestandsliste.LTMittwoch), 0) AS [Durchschnitt LM Mittwoch], Bestandsliste.LMDonnerstag, Bestandsliste.LTDonnerstag, ROUND(IIF(Bestandsliste.LTDonnerstag = 0, 0, Bestandsliste.LMDonnerstag / Bestandsliste.LTDonnerstag), 0) AS [Durchschnitt LM Donnerstag], Bestandsliste.LMFreitag, Bestandsliste.LTFreitag, ROUND(IIF(Bestandsliste.LTFreitag = 0, 0, Bestandsliste.LMFreitag / Bestandsliste.LTFreitag), 0) AS [Durchschnitt LM Freitag], Bestandsliste.LMSamstag, Bestandsliste.LTSamstag, ROUND(IIF(Bestandsliste.LTSamstag = 0, 0, Bestandsliste.LMSamstag / Bestandsliste.LTSamstag), 0) AS [Durchschnitt LM Samstag]
FROM #Bestandsliste AS Bestandsliste
ORDER BY Bestandsliste.Artikelbezeichnung;