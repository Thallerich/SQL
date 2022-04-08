DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

IF OBJECT_ID(N'tempdb..#ReklQuot') IS NOT NULL
  TRUNCATE TABLE #ReklQuot;
ELSE
  CREATE TABLE #ReklQuot (
    Jahr int,
    Geschäftsbereich nchar(5) COLLATE Latin1_General_CS_AS,
    Produktion nvarchar(40) COLLATE Latin1_General_CS_AS,
    Liefermenge bigint,
    Reklamationsmenge bigint
  );

INSERT INTO #ReklQuot (Jahr, Geschäftsbereich, Produktion, Reklamationsmenge, Liefermenge)
SELECT YEAR(LsKo.Datum) AS Jahr, KdGf.KurzBez AS Geschäftsbereich, Standort.Bez AS Produktion, SUM(IIF(LsPoLsKoGru.Reklamation = 1 OR LsKoLsKoGru.Reklamation = 1, ABS(LsPo.Menge), 0)) AS Reklamationsmenge, SUM(IIF(LsPoLsKoGru.Reklamation = 0 OR LsKoLsKoGru.Reklamation = 0, LsPo.Menge, 0)) AS Liefermenge
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
  AND Standort.ID IN ($2$)
  AND KdGf.ID IN ($1$)
  AND Me.IsoCode = N'ST'
GROUP BY YEAR(LsKo.Datum), KdGf.KurzBez, Standort.Bez

SELECT Jahr, Geschäftsbereich, Produktion, Liefermenge, Reklamationsmenge, Reklamationsquote = CAST(ROUND(CAST(Reklamationsmenge AS decimal(15, 3)) / CAST(Liefermenge AS decimal(15, 3)) * 100, 4) AS decimal(7, 4))
FROM #ReklQuot
ORDER BY Produktion, Geschäftsbereich, Jahr;