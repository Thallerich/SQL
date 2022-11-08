DECLARE @HalfYearAgo datetime = DATEADD(day, -180, GETDATE());
DECLARE @KdNr AS TABLE (KdNr int);

INSERT INTO @KdNr VALUES (24045), (11050), (20000), (6071), (7240), (9013), (23041), (23042), (23044), (23032), (23037), (10001756), (242013), (2710499), (2710498), (18029), (245347), (248564), (246805), (10003247), (19080), (20156), (25033), (10001810), (10001671), (10001672), (10001770), (10001816);

DROP TABLE IF EXISTS #TmpSchwundAuto;

SELECT EinzTeil.ID AS EinzTeilID, IIF(EinzTeil.LastErsatzFuerKdArtiID < 0, EinzTeil.ArtikelID, KdArti.ArtikelID) AS ArtikelID, EinzTeil.VsaID AS VsaID
INTO #TmpSchwundAuto
FROM EinzTeil
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzTeil.LastErsatzFuerKdArtiID = KdArti.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE Kunden.KdNr IN (SELECT KdNr FROM @KdNr)
  AND EinzTeil.Status = N'Q'
  AND Bereich.Bereich != N'ST'
  AND EinzTeil.LastActionsID IN (102, 120, 136)
  AND EinzTeil.LastScanTime < @HalfYearAgo;

UPDATE EinzTeil SET [Status] = N'W', LastActionsID = 116
WHERE ID IN (
  SELECT EinzTeilID FROM #TmpSchwundAuto
);

DROP TABLE IF EXISTS #TmpSchwundAuto;