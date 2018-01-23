DECLARE @from date = $4$;
DECLARE @to date = $5$;

DROP TABLE IF EXISTS #Reklamation;

CREATE TABLE #Reklamation (
  Datumsbereich nchar(23),
  Standort nvarchar(40),
  KdNr int,
  Kunde nvarchar(20),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Reklamationsgrund nvarchar(40),
  Reklamationsmenge int
);

INSERT INTO #Reklamation
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Kunden.KdNr AS KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund,  SUM(ABS(LsPo.Menge)) AS Reklamationsmenge
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, Artikel, Standort
WHERE Kunden.ID IN ($1$)
  AND Kunden.ID = Vsa.KundenID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.LsKoGruID = LsKoGru.ID
  AND LsKoGru.ID IN ($3$)
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND Standort.ID IN ($6$)
GROUP BY Standort.Bez, Kunden.KdNr, Kunden.SuchCode, LsKoGru.LsKoGruBez, Artikel.ArtikelNr, Artikel.ArtikelBez
HAVING SUM(ABS(LsPo.Menge)) > 0;

INSERT INTO #Reklamation
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, Artikel, Standort
WHERE Kunden.ID IN ($1$)
  AND Kunden.ID = Vsa.KundenID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsKo.LsKoGruID = LsKoGru.ID
  AND LsPo.LsKoGruID NOT IN ($3$)
  AND LsKoGru.ID IN ($3$)
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND Standort.ID IN ($6$)
GROUP BY Standort.Bez, Kunden.KdNr, Kunden.SuchCode, LsKoGru.LsKoGruBez, Artikel.ArtikelNr, Artikel.ArtikelBez
HAVING SUM(ABS(LsPo.Menge)) > 0;

SELECT Datumsbereich, Standort, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, SUM(Reklamationsmenge) AS Reklamationsmenge 
FROM #Reklamation
GROUP BY Datumsbereich, Standort, KdNr, Kunde, ArtikelNr, Artikelbezeichnung, Reklamationsgrund

UNION

SELECT 'Summe:' AS Datumsbereich, '' AS Standort, NULL AS Kundennummer, '' AS Kundenname, '' AS Artikelnummer, '' AS Artikelbezeichnung, '' AS Reklamationsgrund,  SUM(Reklamationsmenge) AS Reklamationsmenge
FROM #Reklamation;