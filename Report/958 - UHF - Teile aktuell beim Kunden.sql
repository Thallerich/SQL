DECLARE @ErrorMessages TABLE (
  ErrorMessage nvarchar(200)
);

DECLARE @ErrorCount int = 0;

DECLARE @RwConfigID integer;
DECLARE @RwArt integer = 1;
DECLARE @KundenID int;
DECLARE @RwBerechnungsVar int;
DECLARE @ArtiMaxWaschNull int;
DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat)

DECLARE curHoldingKunden CURSOR FOR
  SELECT Kunden.ID
  FROM Kunden
  WHERE (
    (Kunden.ID = $ID$ AND $1$ < 0)
    OR
    (Kunden.HoldingID = $1$ AND $1$ > 0)
  )
;

OPEN curHoldingKunden;

FETCH NEXT FROM curHoldingKunden INTO @KundenID;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @RwConfigID = (SELECT RwPoolTeileConfigID FROM Kunden WHERE ID = @KundenID);
  SET @RwBerechnungsVar = (SELECT RwBerechnungsVar FROM RwConfig WHERE ID = @RwConfigID);
  SET @ArtiMaxWaschNull = 0;

  IF @RwConfigID < 0 BEGIN
    SET @ErrorCount = @ErrorCount + 1;

    INSERT INTO @ErrorMessages
    SELECT N'Kunde ohne Pool-Restwertkonfiguration: ' + RTRIM(CAST(Kunden.KdNr AS nchar(10))) + N' - ' + RTRIM(Kunden.SuchCode) AS ErrorMessage
    FROM Kunden
    WHERE Kunden.ID = @KundenID;
  END;

  IF @RwBerechnungsVar = 2
  BEGIN
    SET @ArtiMaxWaschNull = (
      SELECT COUNT(Artikel.ID)
      FROM Artikel
      JOIN OPTeile ON OPTeile.ArtikelID = Artikel.ID
      JOIN Vsa ON OPTeile.VsaID = Vsa.ID
      WHERE Vsa.KundenID = @KundenID
        AND OPTeile.Status IN (N'Q', N'W')
        AND OPTeile.RechPoID = -1
        AND Artikel.MaxWaschen = 0
    );

    IF @ArtiMaxWaschNull > 0
    BEGIN
      SET @ErrorCount = @ErrorCount + 1;

      INSERT INTO @ErrorMessages
      SELECT N'Artikel ohne definierter Anzahl an maximalen Wäschen: ' + RTRIM(x.ArtikelNr) + N' - ' + RTRIM(x.ArtikelBez) AS ErrorMessage
      FROM (
        SELECT DISTINCT Artikel.ArtikelNr, Artikel.ArtikelBez
        FROM Artikel
        JOIN OPTeile ON OPTeile.ArtikelID = Artikel.ID
        JOIN Vsa ON OPTeile.VsaID = Vsa.ID
        WHERE Vsa.KundenID = @KundenID
          AND OPTeile.Status IN (N'Q', N'W')
          AND OPTeile.RechPoID = -1
          AND Artikel.MaxWaschen = 0
      ) x;
    END;
  END;

  FETCH NEXT FROM curHoldingKunden INTO @KundenID;
END;

CLOSE curHoldingKunden;
DEALLOCATE curHoldingKunden;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Auswertung durchführen                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

IF @ErrorCount > 0
BEGIN
  SELECT * FROM @ErrorMessages ORDER BY ErrorMessage;
END
ELSE
BEGIN

  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, OPTeile.Code AS Chipcode, [Status].StatusBez$LAN$ AS [Status des Teils], REPLACE(Actions.ActionsBez$LAN$, N'OP ', N'') AS [Letzte Aktion], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, OPTeile.LastScanTime AS [Letzter Scan-Zeitpunkt], OPTeile.LastScanToKunde AS [Letzter Auslese-Zeitpunkt], CAST(IIF(OPTeile.RechPoID > 0 AND [Status].[Status] = N'W', 1, 0) AS bit) AS [Teil bereits Schwundverrechnet?], CAST(IIF(OPTeile.RechPoID < -1 AND [Status].[Status] = N'W', 1, 0) AS bit) AS [Teil für Schwundverrechnung gesperrt?], OPTeile.EKGrundAkt AS EKPreis, OPRW.RestwertInfo AS Restwert
  FROM OPTeile
  CROSS APPLY funcGetRestwertOP(OPTeile.ID, @Woche, @RwArt) AS OPRW
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN Actions ON OPTeile.LastActionsID = Actions.ID
  JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND Tabelle = N'OPTEILE'
  WHERE (
      (Kunden.ID = $ID$ AND $1$ < 0)
      OR
      (Kunden.HoldingID = $1$ AND $1$ > 0)
    )
    AND Bereich.ID IN ($2$)
    AND (
      (OPTeile.Status IN (N'Q', N'W') AND OPTeile.LastActionsID IN (102, 116) AND $3$ = 1)
      OR
      (OPTeile.Status = N'Q' AND OPTeile.LastActionsID = 102 AND $3$ = 0)
    );

END;