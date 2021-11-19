BEGIN TRANSACTION;
  DECLARE @MAUpdate TABLE (
    KdBerID int,
    MitarbeiID int
  );

  --SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Hauptstandort, Bereich.BereichBez AS Kundenbereich, Vertreter.Name AS [Vertreter aktuell], _IT53876.Nachname + ', ' + _IT53876.Vorname AS [Vertreter neu], Betreuer.Name AS [Betreuer aktuell], _IT53876.Nachname + ', ' + _IT53876.Vorname AS [Betreuer neu]
  INSERT INTO @MAUpdate (KdBerID, MitarbeiID)
  SELECT KdBer.ID, Mitarbei.ID
  FROM KdBer
  JOIN Kunden ON KdBer.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN _IT53876 ON Kunden.PLZ = _IT53876.PLZ COLLATE Latin1_General_CS_AS
  JOIN Mitarbei ON _IT53876.Nachname COLLATE Latin1_General_CS_AS = Mitarbei.Nachname AND _IT53876.Vorname COLLATE Latin1_General_CS_AS = Mitarbei.Vorname
  WHERE Firma.SuchCode = N'FA14'
    AND KdGf.KurzBez = N'JOB'
    AND Standort.SuchCode IN (N'GRAZ', N'UKLU')
    AND Kunden.AdrArtID = 1
    AND Kunden.Status = N'A';

  -- KdBer updaten
  DECLARE @KdUpdated TABLE (
    KdBerID int,
    VertreterID_old int,
    VertreterID_new int,
    BetreuerID_old int,
    BetreuerID_new int
  );

  UPDATE KdBer SET VertreterID = MAUpdate.MitarbeiID, BetreuerID = MAUpdate.MitarbeiID
  OUTPUT inserted.ID, deleted.VertreterID, inserted.VertreterID, deleted.BetreuerID, inserted.BetreuerID
  INTO @KdUpdated (KdBerID, VertreterID_old, VertreterID_new, BetreuerID_old, BetreuerID_new)
  FROM KdBer
  JOIN @MAUpdate AS MAUpdate ON KdBer.ID = MAUpdate.KdBerID;

  -- VsaBer zu KdBer updaten - Output-Table verwenden!

  UPDATE VsaBer SET VertreterID = KdBer.VertreterID, BetreuerID = KdBer.BetreuerID
  FROM VsaBer
  JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
  WHERE KdBer.ID IN (
    SELECT KdBerID FROM @MAUpdate
  );

  -- Geänderte Daten auswerten

  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Standort.SuchCode AS Hauptstandort, Bereich.BereichBez AS Kundenbereich, VertreterAlt.Name AS [Vertreter bisher], VertreterNeu.Name AS [Vertreter neu], BetreuerAlt.Name AS [Betreuer bisher], BetreuerNeu.Name AS [Betreuer neu]
  FROM @KdUpdated AS KdUpdated
  JOIN KdBer ON KdUpdated.KdBerID = KdBer.ID
  JOIN Kunden ON KdBer.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN Mitarbei AS VertreterAlt ON KdUpdated.VertreterID_old = VertreterAlt.ID
  JOIN Mitarbei AS VertreterNeu ON KdBer.VertreterID = VertreterNeu.ID
  JOIN Mitarbei AS BetreuerAlt ON KdUpdated.BetreuerID_old = BetreuerAlt.ID
  JOIN Mitarbei AS BetreuerNeu ON KdBer.BetreuerID = BetreuerNeu.ID;

-- COMMIT
-- ROLLBACK