/* 
DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\MEDUmbuchung.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

CREATE TABLE __MEDUmbuchen (
  Lagerort nvarchar(20) COLLATE Latin1_General_CS_AS,
  Lagerart nvarchar(60) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Groesse nchar(10) COLLATE Latin1_General_CS_AS,
  Umbuchmenge int
);

SET @XLSXImportSQL = N'SELECT Lagerort, Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, [Teile Med] ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [X$]);';

INSERT INTO __MEDUmbuchen
EXEC sp_executesql @XLSXImportSQL;

DELETE FROM __MEDUmbuchen WHERE ArtikelNr IS NULL;
 */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @ZielLagerart nchar(8) = N'WOLIBKZW';
DECLARE @Ziellagerort int = (SELECT Lagerart.DummyLagerOrtID FROM Lagerart WHERE Lagerart = @ZielLagerart);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Umbuchen TABLE (
  BestandID int,
  BestOrtID int,
  LagerortID int,
  BestandNeu int,
  BestandAlt int
);

DECLARE @Zielbuchung TABLE (
  BestandID int,
  BestandNeu int,
  BestandAlt int
);

BEGIN TRANSACTION;

  WITH Ausbuchen AS (
    SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.ID AS ArtGroeID, ArtGroe.Groesse, Lagerart.ID AS LagerartID, Lagerart.Lagerart, Lagerort.ID AS LagerortID, Lagerort.Lagerort, ImportData.Umbuchmenge
    FROM __MEDUmbuchen AS ImportData
    JOIN Lagerart ON ImportData.Lagerart = Lagerart.LagerartBez
    JOIN Lagerort ON ImportData.Lagerort = Lagerort.Lagerort AND Lagerart.LagerID = Lagerort.LagerID
    JOIN Artikel ON ImportData.ArtikelNr = Artikel.ArtikelNr
    JOIN ArtGroe ON ImportData.Groesse = ArtGroe.Groesse AND Artikel.ID = ArtGroe.ArtikelID
    WHERE ImportData.Umbuchmenge > 0
  )
  UPDATE BestOrt SET BestOrt.Bestand = BestOrt.Bestand - IIF(Ausbuchen.Umbuchmenge > BestOrt.Bestand, BestOrt.Bestand, Ausbuchen.Umbuchmenge)
  OUTPUT inserted.BestandID, inserted.ID, inserted.LagerOrtID, inserted.Bestand, deleted.Bestand
  INTO @Umbuchen
  FROM BestOrt
  JOIN Bestand ON BestOrt.BestandID = Bestand.ID
  JOIN Ausbuchen ON Bestand.LagerArtID = Ausbuchen.LagerartID AND Bestand.ArtGroeID = Ausbuchen.ArtGroeID AND BestOrt.LagerOrtID = Ausbuchen.LagerortID;

  WITH Bestandsanpassung AS (
    SELECT Umbuchen.BestandID, SUM(BestandAlt - BestandNeu) AS Differenz
    FROM @Umbuchen AS Umbuchen
    GROUP BY Umbuchen.BestandID
    HAVING SUM(BestandAlt - BestandNeu) != 0
  )
  UPDATE Bestand SET Bestand.Bestand = Bestand.Bestand - Bestandsanpassung.Differenz
  FROM Bestand
  JOIN Bestandsanpassung ON Bestandsanpassung.BestandID = Bestand.ID;

  INSERT INTO LagerBew (BestandID, BuchDatum, Zeitpunkt, BenutzerID, LgBewCodID, LagerortID, Differenz, BestandNeu, BestNeuValuta, DiffWert, WertNeu, WertNeuValuta, EPreis, GleitPreis, FixWertModus)
  SELECT LgBew.BestandID, CAST(GETDATE() AS date) AS BuchDatum, GETDATE() AS Zeitpunkt, @UserID AS BenutzerID, 62 AS LgBewCodID, LgBew.LagerortID AS LagerOrt, (LgBew.BestandAlt - LgBew.BestandNeu) * -1 AS Differenz, LgBew.BestandNeu, LgBew.BestandNeu AS BestNeuValuta, (LgBew.BestandAlt - LgBew.BestandNeu) * -1 * Bestand.GleitPreis AS DiffWert, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeu, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeuValuta, Bestand.GleitPreis AS EPreis, Bestand.GleitPreis, 7 AS FixWertModus
  FROM @Umbuchen AS LgBew
  JOIN Bestand ON LgBew.BestandID = Bestand.ID;

  WITH BestandsanpassungZiellager AS (
    SELECT BestandZiellager.ID AS BestandID, SUM(BestandAlt - BestandNeu) AS Differenz
    FROM @Umbuchen AS Umbuchen
    JOIN Bestand AS BestandQuelllager ON Umbuchen.BestandID = BestandQuelllager.ID
    JOIN Bestand AS BestandZiellager ON BestandQuelllager.ArtGroeID = BestandZiellager.ArtGroeID
    WHERE BestandZiellager.LagerArtID = (SELECT ID FROM Lagerart WHERE Lagerart = @ZielLagerart)
    GROUP BY BestandZiellager.ID
    HAVING SUM(BestandAlt - BestandNeu) != 0
  )
  UPDATE Bestand SET Bestand.Bestand = Bestand.Bestand + BestandsanpassungZiellager.Differenz
  OUTPUT inserted.ID, inserted.Bestand, deleted.Bestand
  INTO @Zielbuchung
  FROM Bestand
  JOIN BestandsanpassungZiellager ON BestandsanpassungZiellager.BestandID = Bestand.ID;

  UPDATE BestOrt SET BestOrt.Bestand = Bestand.Bestand
  FROM BestOrt
  JOIN Bestand ON BestOrt.BestandID = Bestand.ID AND BestOrt.LagerOrtID = @Ziellagerort
  WHERE Bestand.ID IN (SELECT BestandID FROM @Zielbuchung);

  INSERT INTO LagerBew (BestandID, BuchDatum, Zeitpunkt, BenutzerID, LgBewCodID, LagerortID, Differenz, BestandNeu, BestNeuValuta, DiffWert, WertNeu, WertNeuValuta, EPreis, GleitPreis, FixWertModus)
  SELECT LgBew.BestandID, CAST(GETDATE() AS date) AS BuchDatum, GETDATE() AS Zeitpunkt, @UserID AS BenutzerID, 62 AS LgBewCodID, @Ziellagerort AS LagerOrt, (LgBew.BestandAlt - LgBew.BestandNeu) * -1 AS Differenz, LgBew.BestandNeu, LgBew.BestandNeu AS BestNeuValuta, (LgBew.BestandAlt - LgBew.BestandNeu) * -1 * Bestand.GleitPreis AS DiffWert, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeu, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeuValuta, Bestand.GleitPreis AS EPreis, Bestand.GleitPreis, 7 AS FixWertModus
  FROM @Zielbuchung AS LgBew
  JOIN Bestand ON LgBew.BestandID = Bestand.ID;

--ROLLBACK TRANSACTION;

COMMIT TRANSACTION;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

-- DROP TABLE IF EXISTS __MEDUmbuchen;