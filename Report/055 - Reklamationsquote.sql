DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

IF OBJECT_ID(N'tempdb..#ReklQuot') IS NOT NULL
  TRUNCATE TABLE #ReklQuot;
ELSE
  CREATE TABLE #ReklQuot (
    Jahr int,
    Geschäftsbereich nchar(5) COLLATE Latin1_General_CS_AS,
    Produktion nvarchar(40) COLLATE Latin1_General_CS_AS,
    ArtikelID int,
    Liefermenge bigint,
    Reklamationsmenge bigint
  );

INSERT INTO #ReklQuot (Jahr, Geschäftsbereich, Produktion, ArtikelID, Reklamationsmenge, Liefermenge)
SELECT YEAR(LsKo.Datum) AS Jahr, KdGf.KurzBez AS Geschäftsbereich, Standort.Bez AS Produktion, Artikel.ID AS ArtikelID, SUM(IIF(LsPoLsKoGru.Reklamation = 1 OR LsKoLsKoGru.Reklamation = 1, ABS(LsPo.Menge), 0)) AS Reklamationsmenge, SUM(IIF(LsPoLsKoGru.Reklamation = 0 OR LsKoLsKoGru.Reklamation = 0, LsPo.Menge, 0)) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Standort ON LsPo.ProduktionID = Standort.ID
JOIN LsKoGru AS LsKoLsKoGru ON LsKo.LsKoGruID = LsKoLsKoGru.ID
JOIN LsKoGru AS LsPoLsKoGru ON LsPo.LsKoGruID = LsPoLsKoGru.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Me ON Artikel.MeID = Me.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE LsKo.Datum BETWEEN @from AND @to
  AND KdGf.ID IN ($1$)
  AND Kunden.HoldingID IN ($2$)
  AND Standort.ID IN ($3$)
  AND Me.IsoCode = N'ST'
  AND Artikel.ArtiTypeID = 1
GROUP BY YEAR(LsKo.Datum), KdGf.KurzBez, Standort.Bez, Artikel.ID;

SELECT ReklQuot.Jahr, ReklQuot.Geschäftsbereich, ReklQuot.Produktion, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ReklQuot.Liefermenge, ReklQuot.Reklamationsmenge, [Reklamationsquote in %] = CAST(ROUND(CAST(ReklQuot.Reklamationsmenge AS float) / CAST(IIF(ReklQuot.Liefermenge = 0, 1, ReklQuot.Liefermenge) AS float) * 100, 4) AS float)
FROM #ReklQuot AS ReklQuot
JOIN Artikel ON ReklQuot.ArtikelID = Artikel.ID
ORDER BY Produktion, Geschäftsbereich, Jahr;