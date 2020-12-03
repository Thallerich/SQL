DECLARE @Produktion int = $1$;

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, Standort.SuchCode AS Produktionsstandort, FaltProg.Programm AS Faltprogramm, FaltProg.FaltProgBez$LAN$ AS Faltprogrammbezeichnung, FinishPr.Programm AS Finishprogramm, FinishPr.FinishPrBez$LAN$ AS Finishprogrammbezeichnung, Prozess.Prozess AS Bearbeitungsprozess, Prozess.ProzessBez$LAN$ AS Bearbeitungsprozessbezeichnung
FROM ArtiStan
JOIN FaltProg ON ArtiStan.FaltProgID = FaltProg.ID
JOIN FinishPr ON ArtiStan.FinishPrID = FinishPr.ID
JOIN Prozess ON ArtiStan.BearbProzessID = Prozess.ID
JOIN Standort ON ArtiStan.StandortID = Standort.ID
JOIN Artikel ON ArtiStan.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
WHERE Standort.ID = @Produktion
  AND (($2$ = 1 AND (FaltProg.ID < 0 OR FinishPr.ID < 0 OR Prozess.ID < 0)) OR ($2$ = 0))
  AND Artikel.ID > 0
  AND Artikel.ArtiTypeID = 1
  AND EXISTS (
    SELECT Teile.*
    FROM Teile
    JOIN KdArti ON Teile.KdArtiID = KdArti.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    JOIN Vsa ON Teile.VsaID = Vsa.ID
    JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
    JOIN StBerSDC ON StBerSDC.StandBerID = StandBer.ID
    WHERE Teile.ArtikelID = Artikel.ID
      AND Teile.Status BETWEEN N'E' AND N'W'
      AND StandBer.ProduktionID = @Produktion
      AND StBerSDC.SdcDevID = (
        SELECT SdcDev.ID
        FROM SdcDev
        WHERE SdcDev.StandortID = @Produktion
      )
  )
ORDER BY ArtikelNr ASC;