/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepareDate                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;
DECLARE @showvsa bit = $3$;

DROP TABLE IF EXISTS #Reklamation;

CREATE TABLE #Reklamation (
  Datumsbereich nchar(23),
  Lieferdatum date,
  Standort nvarchar(40),
  Geschäftsbereich nchar(5),
  KdNr int,
  Kunde nvarchar(20),
  VsaNr int,
  VsaBez nvarchar(40),
  ArtikelNr nvarchar(15),
  Artikelbezeichnung nvarchar(60),
  Reklamationsgrund nvarchar(40),
  Reklamationsmenge int,
  KundenID int,
  VsaID int,
  KdBerID int
);

IF @showvsa = 1
BEGIN
  INSERT INTO #Reklamation (Datumsbereich, Lieferdatum, Standort, Geschäftsbereich, KdNr, Kunde, VsaNr, VsaBez, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge, KundenID, VsaID, KdBerID)
  SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, LsKo.Datum AS Lieferdatum, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, Kunden.ID AS KundenID, Vsa.ID AS VsaID, KdArti.KdBerID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN LsKoGru ON LsPo.LsKoGruID = LsKoGru.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Kunden.ID IN ($2$)
    AND LsKoGru.ID IN ($4$)
    AND LsKo.Datum BETWEEN @from AND @to
    AND Standort.ID IN ($5$)
    AND Artikel.BereichID IN ($6$)
  GROUP BY LSko.datum,Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsKoGru.LsKoGruBez$LAN$, Kunden.ID, Vsa.ID, KdArti.KdBerID
  HAVING SUM(ABS(LsPo.Menge)) > 0;

  INSERT INTO #Reklamation (Datumsbereich, Lieferdatum, Standort, Geschäftsbereich, KdNr, Kunde, VsaNr, VsaBez, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge, KundenID, VsaID, KdBerID)
  SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, LsKo.Datum AS Lieferdatum, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kundenname, Vsa.VsaNr, Vsa.Bez AS VsaBez, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, Kunden.ID AS KundenID, Vsa.ID AS VsaID, KdArti.KdBerID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN LsKoGru ON LsKo.LsKoGruID = LsKoGru.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Kunden.ID IN ($2$)
    AND LsPo.LsKoGruID NOT IN ($4$)
    AND LsKoGru.ID IN ($4$)
    AND LsKo.Datum BETWEEN @from AND @to
    AND Standort.ID IN ($5$)
    AND Artikel.BereichID IN ($6$)
  GROUP BY LSko.datum,Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsKoGru.LsKoGruBez$LAN$, Kunden.ID, Vsa.ID, KdArti.KdBerID
  HAVING SUM(ABS(LsPo.Menge)) > 0;
END
ELSE
BEGIN
  INSERT INTO #Reklamation (Datumsbereich, Lieferdatum, Standort, Geschäftsbereich, KdNr, Kunde, VsaNr, VsaBez, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge, KundenID, KdBerID)
  SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, LsKo.Datum AS Lieferdatum, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, NULL AS VsaNr, NULL AS VsaBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund,  SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, Kunden.ID AS KundenID, KdArti.KdBerID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN LsKoGru ON LsPo.LsKoGruID = LsKoGru.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Kunden.ID IN ($2$)
    AND LsKoGru.ID IN ($4$)
    AND LsKo.Datum BETWEEN @from AND @to
    AND Standort.ID IN ($5$)
    AND Artikel.BereichID IN ($6$)
  GROUP BY LSko.datum,Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsKoGru.LsKoGruBez$LAN$, Kunden.ID, KdArti.KdBerID
  HAVING SUM(ABS(LsPo.Menge)) > 0;

  INSERT INTO #Reklamation (Datumsbereich, Lieferdatum, Standort, Geschäftsbereich, KdNr, Kunde, VsaNr, VsaBez, ArtikelNr, Artikelbezeichnung, Reklamationsgrund, Reklamationsmenge, KundenID, KdBerID)
  SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, LsKo.Datum AS Lieferdatum, Standort.Bez AS Standort, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kundenname, NULL AS VsaNr, NULL AS VsaBez, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKoGru.LsKoGruBez$LAN$ AS Reklamationsgrund, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, Kunden.ID AS KundenID, KdArti.KdBerID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN LsKoGru ON LsKo.LsKoGruID = LsKoGru.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Kunden.ID IN ($2$)
    AND LsPo.LsKoGruID NOT IN ($4$)
    AND LsKoGru.ID IN ($4$)
    AND LsKo.Datum BETWEEN @from AND @to
    AND Standort.ID IN ($5$)
    AND Artikel.BereichID IN ($6$)
  GROUP BY LSko.datum,Standort.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsKoGru.LsKoGruBez$LAN$, Kunden.ID, KdArti.KdBerID
  HAVING SUM(ABS(LsPo.Menge)) > 0;
END;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Datumsbereich,
  Lieferdatum,
  Standort,
  Geschäftsbereich,
  KdNr,
  Kunde,
  VsaNr,
  [VSA-Bezeichnung] = VsaBez,
  ArtikelNr,
  Artikelbezeichnung,
  Reklamationsgrund,
  Reklamationsmenge,
  Kundenservice = (
    SELECT TOP 1 Mitarbei.Name
    FROM VsaBer
    JOIN Mitarbei ON VsaBer.ServiceID = Mitarbei.ID
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    WHERE VsaBer.KdBerID = #Reklamation.KdBerID
      AND KdBer.KundenID = #Reklamation.KundenID
      AND VsaBer.VsaID = COALESCE(#Reklamation.VsaID, VsaBer.VsaID)
  ),
  Kundenbetreuer = (
    SELECT TOP 1 Mitarbei.Name
    FROM VsaBer
    JOIN Mitarbei ON VsaBer.BetreuerID = Mitarbei.ID
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    WHERE VsaBer.KdBerID = #Reklamation.KdBerID
      AND KdBer.KundenID = #Reklamation.KundenID
      AND VsaBer.VsaID = COALESCE(#Reklamation.VsaID, VsaBer.VsaID)
  )
FROM #Reklamation

UNION ALL

SELECT 'Summe:' AS Datumsbereich, NULL AS Lieferdatum, NULL AS Standort, NULL AS Geschäftsbereich, NULL AS Kundennummer, NULL AS Kundenname, NULL AS VsaNr, NULL AS [VSA-Bezeichnung],  NULL AS Artikelnummer, NULL AS Artikelbezeichnung, NULL AS Reklamationsgrund,  SUM(Reklamationsmenge) AS Reklamationsmenge, NULL AS Kundenservice, NULL AS Kundenbetreuer
FROM #Reklamation;