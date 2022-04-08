DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

IF OBJECT_ID(N'tempdb..#ReklQuot') IS NOT NULL
  TRUNCATE TABLE #ReklQuot;
ELSE
  CREATE TABLE #ReklQuot (
    Jahr int,
    Produktion nvarchar(40) COLLATE Latin1_General_CS_AS,
    Liefermenge bigint,
    Reklamationsmenge bigint
  );

INSERT INTO #ReklQuot (Jahr, Produktion, Reklamationsmenge, Liefermenge)
SELECT YEAR(LsKo.Datum) AS Jahr, Standort.Bez AS Produktion, SUM(IIF(LsPoLsKoGru.Reklamation = 1 OR LsKoLsKoGru.Reklamation = 1, ABS(LsPo.Menge), 0)) AS Reklamationsmenge, SUM(IIF(LsPoLsKoGru.Reklamation = 0 OR LsKoLsKoGru.Reklamation = 0, LsPo.Menge, 0)) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Standort ON LsPo.ProduktionID = Standort.ID
JOIN LsKoGru AS LsKoLsKoGru ON LsKo.LsKoGruID = LsKoLsKoGru.ID
JOIN LsKoGru AS LsPoLsKoGru ON LsPo.LsKoGruID = LsPoLsKoGru.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Me ON Artikel.MeID = Me.ID
WHERE LsKo.Datum BETWEEN @from AND @to
  AND Standort.ID IN ($1$)
  AND Me.IsoCode = N'ST'
GROUP BY YEAR(LsKo.Datum), Standort.Bez

SELECT Jahr, Produktion, Liefermenge, Reklamationsmenge, Reklamationsquote = CAST(ROUND(CAST(Reklamationsmenge AS decimal(15, 3)) / CAST(Liefermenge AS decimal(15, 3)) * 100, 4) AS decimal(7, 4))
FROM #ReklQuot
ORDER BY Produktion, Jahr;