/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Auswertung für Vorab-Prüfung                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT InKalk.Prio,
  IIF(Firma.ID < 0, N'-', Firma.Bez) AS Firma,
  IIF(Produktion.ID < 0, N'-', Produktion.Bez) AS Produktionsstandort,
  IIF(Expedition.ID < 0, N'-', Expedition.Bez) AS Expeditionsstandort,
  IIF(Bereich.ID < 0, N'-', Bereich.BereichBez) AS Bereich,
  IIF(Kunden.ID < 0, N'-', CONCAT(CAST(Kunden.KdNr AS nvarchar), N': ', Kunden.Name1)) AS Kunde,
  IIF(Artikel.ID < 0, N'-', CONCAT(Artikel.ArtikelNr, N': ', Artikel.ArtikelBez)) AS Artikel,
  IIF(Wae.ID < 0, N'-', Wae.Code) AS Währung,
  InKalk.InKalkWaschPreis AS [Bearbeitung fest],
  InKalk.InKalkWaschProzent AS [Bearbeitung %],
  InKalk.InKalkLeasPreis AS [Leasing fest],
  CAST(ROUND(InKalk.InKalkLeasPreis * 1.1, 3) AS money) AS [Leasing fest + 10%],
  InKalk.InKalkLeasProzent AS [Leasing %],
  InKalk.InKalkSplitPreis AS [Bearbeitung und Leasing fest],
  InKalk.InKalkSplitProzent AS [Bearbeitung und Leasing %]
FROM InKalk
JOIN Firma ON InKalk.FirmaID = Firma.ID
JOIN Standort AS Produktion ON InKalk.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON InKalk.ExpeditionID = Expedition.ID
JOIN Bereich ON InKalk.BereichID = Bereich.ID
JOIN Kunden ON InKalk.KundenID = Kunden.ID
JOIN Artikel ON InKalk.ArtikelID = Artikel.ID
JOIN Wae ON InKalk.WaeID = Wae.ID
WHERE (Firma.SuchCode = N'FA14' OR Firma.ID < 0)
  --AND (Bereich.Bereich = N'BK' OR Artikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'BK') OR (Bereich.ID < 0 AND Artikel.ID < 0))
  AND InKalk.InKalkLeasPreis != 0;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Anpassung durchführen                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #InKalk;
GO

SELECT InKalk.ID AS InKalkID,
  CAST(ROUND(InKalk.InKalkLeasPreis * 1.1, 3) AS money) AS InKalkLeasPreis_Neu
INTO #InKalk
FROM InKalk WITH (UPDLOCK)
JOIN Firma ON InKalk.FirmaID = Firma.ID
JOIN Standort AS Produktion ON InKalk.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON InKalk.ExpeditionID = Expedition.ID
JOIN Bereich ON InKalk.BereichID = Bereich.ID
JOIN Kunden ON InKalk.KundenID = Kunden.ID
JOIN Artikel ON InKalk.ArtikelID = Artikel.ID
JOIN Wae ON InKalk.WaeID = Wae.ID
WHERE (Firma.SuchCode = N'FA14' OR Firma.ID < 0)
  --AND (Bereich.Bereich = N'BK' OR Artikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'BK') OR (Bereich.ID < 0 AND Artikel.ID < 0))
  AND InKalk.InKalkLeasPreis != 0;

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE InKalk SET InKalkLeasPreis = #InKalk.InKalkLeasPreis_Neu
    FROM #InKalk
    WHERE #InKalk.InKalkID = InKalk.ID;
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO

DROP TABLE IF EXISTS #InKalk;
GO