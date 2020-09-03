DECLARE @OldArtiNr nchar(15) = N'A98G';
DECLARE @NewArtiNr nchar(15) = N'97H1';
DECLARE @Lagerart nchar(10) = N'BRATBKGC';
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

WITH NewArti AS (
  SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, ArtGroe.ID AS ArtGroeID, ArtGroe.Groesse
  FROM ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Artikel.ArtikelNr = @NewArtiNr
)
UPDATE TeileLag SET TeileLag.ArtGroeID = NewArti.ArtGroeID, TeileLag.UserID_ = @UserID
--SELECT NewArti.ArtikelNr, NewArti.Groesse, Artikel.ArtikelNr AS OldArtikelNr, ArtGroe.Groesse AS OldGroesse, TeileLag.*
FROM TeileLag
JOIN ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON TeileLag.LagerartID = Lagerart.ID
JOIN NewArti ON NewArti.Groesse = ArtGroe.Groesse
WHERE Artikel.ArtikelNr = @OldArtiNr
  AND Lagerart.Lagerart = @Lagerart
  AND Teilelag.Status = N'L';

DECLARE @Bestandskorrektur TABLE (
  BestandID int,
  LagerortID int,
  ArtikelID int,
  Bestand int
);

DECLARE @LagerBew TABLE (
  BestandID int,
  Differenz int,
  BestandNeu int
);

WITH Vergleich
AS (
 SELECT Bestand.ID BestandID, Bestand.ArtGroeID, Bestand.LagerArtID, TeileLag.LagerortID, Artikel.ID AS ArtikelID, SUM(IIF(TeileLag.ID IS NULL, 0, 1)) AnzTeileLag
  FROM Bestand
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  LEFT JOIN TeileLag ON Bestand.ArtGroeID = TeileLag.ArtGroeID AND Bestand.LagerArtID = TeileLag.LagerArtID AND TeileLag.STATUS < N'Y'
  WHERE Bestand.LagerArtID IN (
      SELECT LagerArt.ID
      FROM LagerArt
      WHERE LagerArt.Barcodiert = 1
        AND Lagerart.Lagerart = @Lagerart
      )
    AND Artikel.ArtikelNr IN (@OldArtiNr, @NewArtiNr)
  GROUP BY Bestand.ID, Bestand.ArtGroeID, Bestand.LagerArtID, TeileLag.LagerortID, Artikel.ID
)
INSERT INTO @Bestandskorrektur
SELECT Vergleich.BestandID, Vergleich.LagerortID, Vergleich.ArtikelID, AnzTeileLag AS Bestand
FROM Vergleich
LEFT JOIN BestOrt ON BestOrt.BestandID = Vergleich.BestandID AND BestOrt.LagerOrtID = Vergleich.LagerOrtID
WHERE ISNULL(BestOrt.Bestand, 0) != Vergleich.AnzTeileLag;

--SELECT * FROM @Bestandskorrektur;

MERGE INTO BestOrt
USING (
  SELECT Bestandskorrektur.BestandID, Bestandskorrektur.LagerortID, Bestandskorrektur.ArtikelID, Bestandskorrektur.Bestand
  FROM @Bestandskorrektur AS Bestandskorrektur
) AS TeilebestandOrt
ON BestOrt.BestandID = TeilebestandOrt.BestandID AND BestOrt.LagerortID = TeilebestandOrt.LagerortID
WHEN MATCHED THEN
  UPDATE SET Bestand = TeilebestandOrt.Bestand
WHEN NOT MATCHED THEN
  INSERT (BestandID, LagerortID, ArtikelID, Bestand)
  VALUES (TeilebestandOrt.BestandID, TeilebestandOrt.LagerortID, TeilebestandOrt.ArtikelID, TeilebestandOrt.Bestand);

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
SELECT LgBew.BestandID, CAST(GETDATE() AS date) AS BuchDatum, GETDATE() AS Zeitpunkt, @UserID AS BenutzerID, 14 AS LgBewCodID, -1 AS LagerOrt, LgBew.Differenz, LgBew.BestandNeu, LgBew.BestandNeu AS BestNeuValuta, LgBew.Differenz * Bestand.GleitPreis AS DiffWert, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeu, LgBew.BestandNeu * Bestand.GleitPreis AS WertNeuValuta, Bestand.GleitPreis AS EPreis, Bestand.GleitPreis, 0 AS FixWertModus
FROM @LagerBew AS LgBew
JOIN Bestand ON LgBew.BestandID = Bestand.ID;