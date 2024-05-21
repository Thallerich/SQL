DROP TABLE IF EXISTS #ArtiStanCheck;

CREATE TABLE #ArtiStanCheck (
  ArtikelID int,
  StandortID int,
  FaltProgID int,
  FinishPrID int,
  BearbProzessID int
);

DECLARE @Produktion TABLE (
  ProduktionID int
);

INSERT INTO @Produktion (ProduktionID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($1$)
  AND Standort.Produktion = 1;

IF $1$ = 5175
  INSERT INTO @Produktion (ProduktionID)
  VALUES (1), (4535), (5006), (5008), (5175);

IF $1$ = 2
  INSERT INTO @Produktion (ProduktionID)
  VALUES (4), (4547), (5005), (5007), (5010), (5011);
  

INSERT INTO #ArtiStanCheck (ArtikelID, StandortID, FaltProgID, FinishPrID, BearbProzessID)
SELECT ArtiStan.ArtikelID, ArtiStan.StandortID, ArtiStan.FaltProgID, ArtiStan.FinishPrID, ArtiStan.BearbProzessID
FROM ArtiStan
WHERE ArtiStan.StandortID IN (SELECT ProduktionID FROM @Produktion);

MERGE INTO #ArtiStanCheck
USING (
  SELECT Artikel.ID AS ArtikelID, FaltProg.ID AS FaltProgID, FinishPr.ID AS FinishPrID
  FROM Artikel
  CROSS JOIN (SELECT ID FROM FaltProg WHERE IstDefault = 1) AS FaltProg
  CROSS JOIN (SELECT ID FROM FinishPr WHERE IstDefault = 1) AS FinishPr
) AS ArtiStanDefault
ON #ArtiStanCheck.ArtikelID = ArtiStanDefault.ArtikelID
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, StandortID, FaltProgID, FinishPrID, BearbProzessID)
  VALUES (ArtiStanDefault.ArtikelID, -9, ArtiStanDefault.FaltProgID, ArtiStanDefault.FinishPrID, -1);

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, Standort.ID AS StandortID, Standort.SuchCode AS Produktionsstandort, FaltProg.Programm AS Faltprogramm, FaltProg.FaltProgBez$LAN$ AS Faltprogrammbezeichnung, FinishPr.Programm AS Finishprogramm, FinishPr.FinishPrBez$LAN$ AS Finishprogrammbezeichnung, Prozess.Prozess AS Bearbeitungsprozess, Prozess.ProzessBez$LAN$ AS Bearbeitungsprozessbezeichnung
FROM #ArtiStanCheck AS ArtiStan
JOIN FaltProg ON ArtiStan.FaltProgID = FaltProg.ID
JOIN FinishPr ON ArtiStan.FinishPrID = FinishPr.ID
JOIN Prozess ON ArtiStan.BearbProzessID = Prozess.ID
JOIN (
  SELECT ID, SuchCode
  FROM Standort

  UNION

  SELECT -9 AS ID, N'Alle Standorte' AS SuchCode
) AS Standort ON ArtiStan.StandortID = Standort.ID
JOIN Artikel ON ArtiStan.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
WHERE (($2$ = 1 AND (FaltProg.ID < 0 OR FinishPr.ID < 0 OR Prozess.ID < 0)) OR ($2$ = 0))
  AND Artikel.ID > 0
  AND Artikel.ArtiTypeID = 1
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    JOIN Vsa ON EinzHist.VsaID = Vsa.ID
    JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
    JOIN StBerSDC ON StBerSDC.StandBerID = StandBer.ID
    WHERE EinzHist.ArtikelID = Artikel.ID
      AND EinzHist.Status BETWEEN N'E' AND N'W'
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.TraegerID > 0
      AND (StandBer.ProduktionID IN (SELECT ProduktionID FROM @Produktion) OR Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = 100151))
      AND StBerSDC.SdcDevID IN (
        SELECT SdcDev.ID
        FROM SdcDev
        WHERE SdcDev.StandortID IN (SELECT ProduktionID FROM @Produktion)
      )
  )
ORDER BY ArtikelNr ASC;