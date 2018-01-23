DECLARE @from date = $4$;
DECLARE @to date = $5$;

DROP TABLE IF EXISTS #Reklamation846a;

CREATE TABLE #Reklamation846a (
  Datumsbereich nchar(23),
  Standort nvarchar(40),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Reklamationsmenge int,
  Liefermenge int,
  Stückpreis money,
  KdNr int,
  Kunde nvarchar(20)
);

INSERT INTO #Reklamation846a
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,  SUM(IIF(LsPo.LsKoGruID > 0, ABS(LsPo.Menge), 0)) AS Reklamationsmenge, SUM(IIF(LsPo.LsKoGruID > 0, 0, ABS(LsPo.Menge))) AS Liefermenge, KdArti.WaschPreis AS Stückpreis, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden, Vsa, LsKo, LsPo, KdArti, Artikel, Standort
WHERE Kunden.ID = Vsa.KundenID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND LsKo.LsKoGruID NOT IN ($3$)
  AND Standort.ID IN ($6$)
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.WaschPreis, Kunden.KdNr, Kunden.SuchCode;
--HAVING SUM(IIF(LsPo.LsKoGruID IN ($3$), ABS(LsPo.Menge), 0)) > 0;

INSERT INTO #Reklamation846a
SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,  SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, 0 AS Liefermenge, KdArti.WaschPreis AS Stückpreis, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden, Vsa, LsKo, LsPo, KdArti, Artikel, Standort
WHERE Kunden.ID = Vsa.KundenID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND LsKo.LsKoGruID IN ($3$)
  AND Standort.ID IN ($6$)
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.WaschPreis, Kunden.KdNr, Kunden.SuchCode;
--HAVING SUM(ABS(LsPo.Menge)) > 0;

SELECT Datumsbereich, Standort, ArtikelNr, Artikelbezeichnung, SUM(Reklamationsmenge) AS Reklamationsmenge, SUM(Liefermenge) AS Liefermenge, Stückpreis, KdNr, Kunde 
FROM #Reklamation846a 
GROUP BY Datumsbereich, Standort, ArtikelNr, Artikelbezeichnung, Stückpreis, KdNr, Kunde
HAVING SUM(Reklamationsmenge) > 0
ORDER BY KdNr ASC;