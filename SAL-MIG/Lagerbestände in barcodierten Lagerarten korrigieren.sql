BEGIN TRANSACTION

  DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

  DECLARE @Bestandskorrektur TABLE (
    BestandID int,
    BestOrtID int,
    Bestand int
  );

  DECLARE @LagerBew TABLE (
    BestandID int,
    Differenz int,
    BestandNeu int
  );

  WITH Vergleich
  AS (
    SELECT Bestand.ID BestandID, Bestand.ArtGroeID, Bestand.LagerArtID, BestOrt.ID AS BestOrtID, BestOrt.LagerOrtID, BestOrt.Bestand BestOrtBestand, SUM(IIF(TeileLag.ID IS NULL, 0, 1)) AnzTeileLag
    FROM Bestand
    INNER JOIN BestOrt ON (Bestand.ID = BestOrt.BestandID)
    LEFT JOIN TeileLag ON (
        Bestand.ArtGroeID = TeileLag.ArtGroeID
        AND Bestand.LagerArtID = TeileLag.LagerArtID
        AND BestOrt.LagerOrtID = TeileLag.LagerOrtID
        AND TeileLag.STATUS < N'Y'
        )
    WHERE Bestand.LagerArtID IN (
        SELECT LagerArt.ID
        FROM LagerArt
        WHERE LagerArt.Barcodiert = 1
        )
    GROUP BY Bestand.ID, Bestand.ArtGroeID, Bestand.LagerArtID, BestOrt.ID, BestOrt.LagerOrtID, BestOrt.Bestand
  )
  INSERT INTO @Bestandskorrektur
  SELECT BestandID, BestOrtID, AnzTeileLag AS Bestand
  FROM Vergleich
  WHERE BestOrtBestand <> AnzTeileLag;

  --SELECT * FROM @Bestandskorrektur;

  UPDATE BestOrt SET Bestand = Bestandskorrektur.Bestand
  --SELECT BestOrt.ID, BestOrt.Bestand, Bestandskorrektur.Bestand AS KorrBestand
  FROM Bestort
  JOIN @Bestandskorrektur AS Bestandskorrektur ON Bestandskorrektur.BestOrtID = BestOrt.ID;

  WITH Bestandskorrektur AS (
    SELECT Bestandskorrektur.BestandID, SUM(BestOrt.Bestand) AS Bestand
    FROM @Bestandskorrektur AS Bestandskorrektur
    JOIN BestOrt ON Bestandskorrektur.BestandID = BestOrt.BestandID
    GROUP BY Bestandskorrektur.BestandID
  )
  UPDATE Bestand SET Bestand = Bestandskorrektur.Bestand
  OUTPUT inserted.ID AS BestandID, inserted.Bestand AS BestandNeu, inserted.Bestand - deleted.Bestand AS Differenz
  INTO @LagerBew (BestandID, BestandNeu, Differenz)
  --SELECT Bestand.ID, Bestand.Bestand, Bestandskorrektur.Bestand AS KorrBestand
  FROM Bestand
  JOIN Bestandskorrektur ON Bestandskorrektur.BestandID = Bestand.ID;

  INSERT INTO LagerBew (BestandID, BuchDatum, Zeitpunkt, BenutzerID, LgBewCodID, LagerortID, Differenz, BestandNeu, BestNeuValuta, DiffWert, WertNeu, WertNeuValuta, EPreis, GleitPreis, FixWertModus)
  SELECT LgBew.BestandID, CAST(GETDATE() AS date) AS BuchDatum, GETDATE() AS Zeitpunkt, @UserID AS BenutzerID, 18 AS LgBewCodID, -1 AS LagerOrt, LgBew.Differenz, LgBew.BestandNeu, LgBew.BestandNeu AS BestNeuValuta, LgBew.Differenz * Bestand.GleitPreis AS DiffWert, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeu, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeuValuta, Bestand.GleitPreis AS EPreis, Bestand.GleitPreis, 0 AS FixWertModus
  FROM @LagerBew AS LgBew
  JOIN Bestand ON LgBew.BestandID = Bestand.ID;

COMMIT;
-- ROLLBACK;