DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

DROP TABLE IF EXISTS #Reklamation;

CREATE TABLE #Reklamation (
  Datumsbereich nchar(23),
  LSDatum nvarchar(20),
  Standort nvarchar(40),
  Geschäftsbereich nchar(5),
  KdNr int,
  Kunde nvarchar(20),
  VsaNr int,
  VsaBez nvarchar(40),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Reklamationsgrund nvarchar(40),
  Reklamationsmenge int
);

INSERT INTO #Reklamation (Datumsbereich, LSDatum, Standort, Geschäftsbereich, KdNr, Kunde, VsaNr, VsaBez, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge)
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, LSko.datum, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr AS KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund,  SUM(ABS(LsPo.Menge)) AS Reklamationsmenge
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, Artikel, Standort, KdGf
WHERE Kunden.ID IN ($2$)
  AND Kunden.ID = Vsa.KundenID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.LsKoGruID = LsKoGru.ID
  AND LsKoGru.ID IN ($4$)
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND Kunden.StandortID = Standort.ID
  AND Standort.ID IN ($5$)
  AND Artikel.BereichID IN ($6$)
GROUP BY LSko.datum,Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsKoGru.LsKoGruBez$LAN$
HAVING SUM(ABS(LsPo.Menge)) > 0;

INSERT INTO #Reklamation (Datumsbereich, LSDatum, Standort, Geschäftsbereich, KdNr, Kunde, VsaNr, VsaBez, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge)
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, LSko.datum as LSDatum, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Vsa.VsaNr, Vsa.Bez AS VsaBez, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge
FROM Kunden, Vsa, LsKo, LsKoGru, LsPo, KdArti, Artikel, Standort, KdGf
WHERE Kunden.ID IN ($2$)
  AND Kunden.ID = Vsa.KundenID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsKo.LsKoGruID = LsKoGru.ID
  AND LsPo.LsKoGruID NOT IN ($4$)
  AND LsKoGru.ID IN ($4$)
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND Kunden.StandortID = Standort.ID
  AND Standort.ID IN ($5$)
  AND Artikel.BereichID IN ($6$)
GROUP BY LSko.datum,Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsKoGru.LsKoGruBez$LAN$
HAVING SUM(ABS(LsPo.Menge)) > 0;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Datumsbereich, LSDatum, Standort, Geschäftsbereich, KdNr, Kunde, IIF($3$ = 0, NULL, VsaNr) AS VsaNr, IIF($3$ = 0, NULL, VsaBez) AS [VSA-Bezeichnung], ArtikelNr, Artikelbezeichnung, Reklamationsgrund, SUM(Reklamationsmenge) AS Reklamationsmenge 
FROM #Reklamation
GROUP BY Datumsbereich,LSDatum, Standort, Geschäftsbereich, KdNr, Kunde, IIF($3$ = 0, NULL, VsaNr), IIF($3$ = 0, NULL, VsaBez), ArtikelNr, Artikelbezeichnung, Reklamationsgrund

UNION ALL

SELECT 'Summe:' AS Datumsbereich, NULL AS LSDatum, NULL AS Standort, NULL AS Geschäftsbereich, NULL AS Kundennummer, NULL AS Kundenname, NULL AS VsaNr, NULL AS [VSA-Bezeichnung],  NULL AS Artikelnummer, NULL AS Artikelbezeichnung, NULL AS Reklamationsgrund,  SUM(Reklamationsmenge) AS Reklamationsmenge
FROM #Reklamation;