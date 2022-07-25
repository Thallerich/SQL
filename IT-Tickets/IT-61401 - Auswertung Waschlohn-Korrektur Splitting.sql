DECLARE @SplitLSKO ADVINTEGERLIST;
DECLARE @vonDatum date = N'2022-04-01';
DECLARE @bisDatum date = N'2022-06-30';

INSERT INTO @SplitLSKO
SELECT LsKo.ID
FROM LsKo
WHERE LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND LsKo.SentToSAP != 0
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN Standort ON LsPo.ProduktionID = Standort.ID
    JOIN Firma ON Standort.FirmaID = Firma.ID
    WHERE LsPo.LsKoID = LsKo.ID
      AND Firma.SuchCode = N'FA14'
      AND LsPo.InternKalkPreis = 0
      AND LsPo.Menge != 0
      AND KdArti.WaschPreis != 0
      AND KdArti.LeasPreis != 0
  );

SELECT CAST(YEAR(LsKo.Datum) AS nchar(4)) + N'-' + CAST(MONTH(LsKo.Datum) AS nchar(1)) AS Monat, Firma.SuchCode AS Firma, Expedition.SuchCode AS Expedition, Produktion.SuchCode AS Produktion, SUM(LsPo.Menge * (InKalk.InternKalkAbs + (LsPo.EPreis * InKalk.InternKalkFaktor))) AS Korrektur_Splitting, SUM(LsPo.InternKalkPreis) AS WLBisher
FROM dbo.advFunc_InKalk (@SplitLSKO, @vonDatum, @bisDatum, -1) InKalk
JOIN LsPo ON InKalk.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE InKalk.InKalkArt = N'S'
  AND LsPo.InternKalkPreis != InKalk.InternKalkAbs + (LsPo.EPreis * InKalk.InternKalkFaktor)
  AND LsKo.FahrtID > 0
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC')
GROUP BY CAST(YEAR(LsKo.Datum) AS nchar(4)) + N'-' + CAST(MONTH(LsKo.Datum) AS nchar(1)), Firma.SuchCode, Expedition.SuchCode, Produktion.SuchCode;