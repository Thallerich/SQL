DECLARE @FktCode TABLE (
  BezAlt nvarchar(40) COLLATE Latin1_General_CS_AS,
  BezNeu nvarchar(40) COLLATE Latin1_General_CS_AS,
  Funktionscode nvarchar(8) COLLATE Latin1_General_CS_AS
);

DECLARE @KdAusstaInserted TABLE (
  ID int,
  KundenID int,
  RentomatCode bit,
  Bez nvarchar(40) COLLATE Latin1_General_CS_AS
);
  
INSERT INTO @FktCode VALUES
(N'Ärzte1', N'Ärzte 1/1', N'401'),
(N'Ärzte2', N'Ärzte 2/1', N'402'),
(N'Ärzte5', N'Ärzte 5/1', N'403'),
(N'Ärzte5', N'Ärzte 5/2', N'404'),
(N'DGKS/DGKP', N'DGKS/DGKP /1', N'304'),
(N'DGKS/DGKP10', N'DGKS/DGKP 10/1', N'305'),
(N'DGKS/DGKP3', N'DGKS/DGKP3/1', N'307'),
(N'DGKS/DGKP5', N'DGKS/DGKP 5/1', N'306'),
(N'DGKS/DGKP6', N'DGKS/DGKP 6/1', N'308'),
(N'DGKS/DGKP7', N'DGKS/DGKP 7/1', N'309'),
(N'Helfer1', N'Helfer 1/1', N'310'),
(N'Helfer2', N'Helfer 2/1', N'311'),
(N'Küche1', N'Küche 1/1', N'313'),
(N'Küche1', N'Küche 1/2', N'314'),
(N'Küche2', N'Küche 2/1', N'315'),
(N'Küche8', N'Küche 8/1', N'316'),
(N'Küche9', N'Küche 9/1', N'317'),
(N'Küche9', N'Küche 9/2', N'318'),
(N'Pfl. Helfer1', N'Pfl. Helfer 1/1', N'419'),
(N'Pfl. Helfer1', N'Pfl. Helfer 1/2', N'420'),
(N'Pfl. Helfer4', N'Pfl. Helfer 4/1', N'421'),
(N'Pfl. Helfer4', N'Pfl. Helfer 4/2', N'422'),
(N'Pfl. Helfer6', N'Pfl. Helfer 6/1', N'423'),
(N'Pfl. Helfer6', N'Pfl. Helfer 6/2', N'424'),
(N'PoloDaHose', N'PoloDaHose /1', N'425'),
(N'PoloDaHose', N'PoloDaHose /2', N'426'),
(N'Schüler1', N'Schüler 1/1', N'427'),
(N'Schüler1', N'Schüler 1/2', N'428'),
(N'Schüler1Praktikum', N'Schüler1Praktikum /1', N'429'),
(N'Schüler1Praktikum', N'Schüler1Praktikum /2', N'430'),
(N'Stationssekretärin', N'Stationssekretärin /1', N'431'),
(N'Stationssekretärin', N'Stationssekretärin /2', N'432');

DROP TABLE IF EXISTS #TmpFktCodeCopy;

SELECT RentoCod.RentomatID, FktCode.Funktionscode, FktCode.BezNeu, RentoCod.KreditVorschlag, KdAussta.Bez AS KdAusstaBez, KdAussta.KundenID, KdAussta.RentomatCode, KdAusArt.KdArtiID, KdAusArt.Pos, KdAusArt.Menge, 0 AS KdAusstaIDNeu
INTO #TmpFktCodeCopy
FROM RentoCod
JOIN @FktCode AS FktCode ON RentoCod.Bez = FktCode.BezAlt
JOIN KdAussta ON RentoCod.KdAusstaID = KdAussta.ID
JOIN KdAusArt ON KdAusArt.KdAusstaID = KdAussta.ID
WHERE RentoCod.RentomatID IN (16, 17);

INSERT INTO KdAussta (KundenID, RentomatCode, Bez)
OUTPUT INSERTED.ID, INSERTED.KundenID, INSERTED.RentomatCode, INSERTED.Bez
INTO @KdAusstaInserted
SELECT DISTINCT KundenID, RentomatCode, KdAusstaBez
FROM #TmpFktCodeCopy;

UPDATE #TmpFktCodeCopy SET KdAusstaIDNeu = KdAusstaInserted.ID
FROM #TmpFktCodeCopy
JOIN @KdAusstaInserted AS KdAusstaInserted ON KdAusstaInserted.KundenID = #TmpFktCodeCopy.KundenID AND KdAusstaInserted.RentomatCode = #TmpFktCodeCopy.RentomatCode AND KdAusstaInserted.Bez = #TmpFktCodeCopy.KdAusstaBez;

INSERT INTO KdAusArt (KdAusstaID, KdArtiID, Pos, Menge)
SELECT DISTINCT KdAusstaIDNeu, KdArtiID, Pos, Menge
FROM #TmpFktCodeCopy;

INSERT INTO RentoCod (RentomatID, KdAusstaID, Funktionscode, Bez, KreditVorschlag)
SELECT DISTINCT RentomatID, KdAusstaIDNeu, Funktionscode, BezNeu, KreditVorschlag
FROM #TmpFktCodeCopy;