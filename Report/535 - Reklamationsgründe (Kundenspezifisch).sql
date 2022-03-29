DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

DROP TABLE IF EXISTS #Reklamation;

CREATE TABLE #Reklamation (
  Datumsbereich nchar(23),
  Standort nvarchar(40),
  Geschäftsbereich nchar(5),
  KdNr int,
  Kunde nvarchar(20),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Reklamationsgrund nvarchar(40),
  Reklamationsmenge int
);

INSERT INTO #Reklamation (Datumsbereich, Standort, Geschäftsbereich, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge)
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr AS KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund,  SUM(ABS(LsPo.Menge)) AS Reklamationsmenge
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, Artikel, Standort, KdGf
WHERE Kunden.ID IN ($2$)
  AND Kunden.ID = Vsa.KundenID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.LsKoGruID = LsKoGru.ID
  AND LsKoGru.ID IN ($3$)
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND Standort.ID IN ($4$)
GROUP BY Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, LsKoGru.LsKoGruBez$lan$, Artikel.ArtikelNr, Artikel.ArtikelBez$lan$
HAVING SUM(ABS(LsPo.Menge)) > 0;

INSERT INTO #Reklamation (Datumsbereich, Standort, Geschäftsbereich, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge)
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, Artikel, Standort, KdGf
WHERE Kunden.ID IN ($2$)
  AND Kunden.ID = Vsa.KundenID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsKo.LsKoGruID = LsKoGru.ID
  AND LsPo.LsKoGruID NOT IN ($3$)
  AND LsKoGru.ID IN ($3$)
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND Standort.ID IN ($4$)
GROUP BY Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, LsKoGru.LsKoGruBez$lan$, Artikel.ArtikelNr, Artikel.ArtikelBez$lan$
HAVING SUM(ABS(LsPo.Menge)) > 0;

SELECT Datumsbereich, Standort, Geschäftsbereich, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, SUM(Reklamationsmenge) AS Reklamationsmenge 
FROM #Reklamation
GROUP BY Datumsbereich, Standort, Geschäftsbereich, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Reklamationsgrund

UNION ALL

SELECT 'Summe:' AS Datumsbereich, '' AS Standort, NULL AS Geschäftsbereich, NULL AS Kundennummer, '' AS Kundenname, '' AS Artikelnummer, '' AS Artikelbezeichnung, '' AS Reklamationsgrund,  SUM(Reklamationsmenge) AS Reklamationsmenge
FROM #Reklamation;