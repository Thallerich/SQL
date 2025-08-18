/* GatherData ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpLiefermenge;
 
SELECT LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum, LsKo.VsaID, LsPo.ProduktionID, LsPo.KdArtiID, SUM(LsPo.Menge) AS Menge
INTO #TmpLiefermenge
FROM LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsPo.ProduktionID IN ($3$)
GROUP BY LsKo.ID, LsKo.LsNr, LsKo.Datum, LsKo.VsaID, LsPo.ProduktionID, LsPo.KdArtiID;
 
/* Liefermengen ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Standort.Bez AS Produktion,
  Bereich.BereichBez$LAN$ AS Produktbereich,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  Liefermenge.Menge AS Liefermenge,
  Artikel.StueckGewicht AS [Stückgewicht in kg],
  CAST(Liefermenge.Menge AS decimal(19,4)) * Artikel.StueckGewicht AS [Liefergewicht in kg],
  Artikel.EKPreis,
  Lief.WaeID AS EKPreis_WaeID,
  CAST(CAST(Artikel.EKPreis AS decimal(19,4)) * CAST(Liefermenge.Menge AS decimal(19,4)) AS money) AS [Gesamtwert Einkaufspreis],
  Lief.WaeID AS [Gesamtwert Einkaufspreis_WaeID]
FROM (
  SELECT Vsa.KundenID, #TmpLiefermenge.ProduktionID, KdArti.ArtikelID, SUM(#TmpLiefermenge.Menge) AS Menge
  FROM #TmpLiefermenge
  JOIN KdArti ON #TmpLiefermenge.KdArtiID = KdArti.ID
  JOIN Vsa ON #TmpLiefermenge.VsaID = Vsa.ID
  GROUP BY Vsa.KundenID, #TmpLiefermenge.ProduktionID, KdArti.ArtikelID
) AS Liefermenge
JOIN Standort ON Liefermenge.ProduktionID = Standort.ID
JOIN Artikel ON Liefermenge.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Kunden ON Liefermenge.KundenID = Kunden.ID
JOIN Lief ON Artikel.LiefID = Lief.ID
WHERE Bereich.ID IN ($4$)
  AND Kunden.ID in ($5$)
ORDER BY Produktion, KdNr, Produktbereich, ArtikelNr;

/* Liefermengen mit LS-Nummer ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Standort.Bez AS Produktion,
  Bereich.BereichBez$LAN$ AS Produktbereich,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  Liefermenge.LsKoID,
  Liefermenge.LsNr,
  Liefermenge.Datum AS Lieferdatum,
  Liefermenge.Menge AS Liefermenge,
  Artikel.StueckGewicht AS [Stückgewicht in kg],
  CAST(Liefermenge.Menge AS decimal(19,4)) * CAST(Artikel.StueckGewicht AS decimal(19, 4)) AS [Liefergewicht in kg],
  Artikel.EKPreis,
  Lief.WaeID AS EKPreis_WaeID,
  CAST(CAST(Artikel.EKPreis AS decimal(19,4)) * CAST(Liefermenge.Menge AS decimal(19,4)) AS money) AS [Gesamtwert Einkaufspreis],
  Lief.WaeID AS [Gesamtwert Einkaufspreis_WaeID]
FROM #TmpLiefermenge AS Liefermenge, Standort, KdArti, Artikel, Bereich, Kunden, Lief
WHERE LieferMenge.ProduktionID = Standort.ID
  AND LieferMenge.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Artikel.LiefID = Lief.ID
  AND KdArti.KundenID = Kunden.ID
  AND Bereich.ID IN ($4$)
  AND Kunden.ID in ($5$)
ORDER BY Produktion, KdNr, Produktbereich, ArtikelNr;

/* Liefermengen kumuliert VSA und Tag ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Standort.Bez AS Produktion,
  Bereich.BereichBez$LAN$ AS Produktbereich,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.PLZ,
  Vsa.Ort,
  StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration],
  Liefermenge.Datum AS Lieferdatum,
  Liefermenge.Menge AS Liefermenge,
  CAST(Liefermenge.Menge AS decimal(19,4)) * Artikel.StueckGewicht AS [Liefergewicht in kg],
  CAST(CAST(Artikel.EKPreis AS decimal(19,4)) * CAST(Liefermenge.Menge AS decimal(19,4)) AS money) AS [Gesamtwert Einkaufspreis],
  Lief.WaeID AS [Gesamtwert Einkaufspreis_WaeID]
FROM (
  SELECT #TmpLiefermenge.VsaID, #TmpLiefermenge.Datum, #TmpLiefermenge.ProduktionID, KdArti.ArtikelID, SUM(#TmpLiefermenge.Menge) AS Menge
  FROM #TmpLiefermenge
  JOIN KdArti ON #TmpLiefermenge.KdArtiID = KdArti.ID
  GROUP BY #TmpLiefermenge.VsaID, #TmpLiefermenge.Datum, #TmpLiefermenge.ProduktionID, KdArti.ArtikelID
) AS Liefermenge
JOIN Standort ON Liefermenge.ProduktionID = Standort.ID
JOIN Artikel ON Liefermenge.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Vsa ON Liefermenge.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
WHERE Bereich.ID IN ($4$)
  AND Kunden.ID in ($5$)
ORDER BY Produktion, KdNr, Produktbereich, Lieferdatum;