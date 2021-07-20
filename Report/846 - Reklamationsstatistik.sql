DROP TABLE IF EXISTS #Reklamation846;

CREATE TABLE #Reklamation846 (
  Datumsbereich nchar(23),
  Standort nvarchar(40),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Reklamationsmenge int,
  Liefermenge int
);

INSERT INTO #Reklamation846
SELECT FORMAT($STARTDATE$, 'd', 'de-at') + ' - ' + FORMAT($ENDDATE$, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(IIF(LsPo.LsKoGruID > 0, ABS(LsPo.Menge), 0)) AS Reklamationsmenge, SUM(IIF(LsPo.LsKoGruID > 0, 0, ABS(LsPo.Menge))) AS Liefermenge
FROM LsKo, LsPo, Artikel, Standort, KdArti
WHERE LsKo.ID = LsPo.LsKoID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND LsKo.ProduktionID = Standort.ID
  AND LsKo.LsKoGruID NOT IN ($3$)
  AND Standort.ID IN ($6$)
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
HAVING SUM(IIF(LsPo.LsKoGruID IN ($3$), ABS(LsPo.Menge), 0)) > 0;

INSERT INTO #Reklamation846
SELECT FORMAT($STARTDATE$, 'd', 'de-at') + ' - ' + FORMAT($ENDDATE$, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, 0 AS Liefermenge
FROM LsKo, LsPo, Artikel, Standort, KdArti
WHERE LsKo.ID = LsPo.LsKoID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND LsKo.ProduktionID = Standort.ID
  AND LsKo.LsKoGruID IN ($3$)
  AND Standort.ID IN ($6$)
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
HAVING SUM(ABS(LsPo.Menge)) > 0;

SELECT Datumsbereich, Standort, ArtikelNr, Artikelbezeichnung, SUM(Reklamationsmenge) AS Reklamationsmenge, SUM(Liefermenge) AS Liefermenge, IIF(SUM(Liefermenge) = 0, NULL, ROUND((CAST(100 AS float) / SUM(Liefermenge)) * SUM(Reklamationsmenge), 2)) AS [reklamiert %]
FROM #Reklamation846
GROUP BY Datumsbereich, Standort, ArtikelNr, Artikelbezeichnung
ORDER BY ArtikelNr ASC;