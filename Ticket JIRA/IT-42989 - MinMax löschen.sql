CREATE TABLE __MinMax_LEGW_20210104 (
  BestandID int,
  Minimum int,
  Maximum int,
  ArtGroeID int,
  LagerartID int
);

UPDATE Bestand SET Bestand.Minimum = __MinMax_loeschen_LEGW.MinNeu, Bestand.Maximum = __MinMax_loeschen_LEGW.MaxNeu
OUTPUT deleted.ID, deleted.Minimum, deleted.Maximum, deleted.ArtGroeID, deleted.LagerArtID
INTO __MinMax_LEGW_20210104 (BestandID, Minimum, Maximum, ArtGroeID, LagerartID)
FROM __MinMax_loeschen_LEGW
JOIN Artikel ON __MinMax_loeschen_LEGW.ArtNr = Artikel.ArtikelNr COLLATE Latin1_General_CS_AS
JOIN ArtGroe ON __MinMax_loeschen_LEGW.Groesse = ArtGroe.Groesse COLLATE Latin1_General_CS_AS AND ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON __MinMax_loeschen_LEGW.LagerartBez = Lagerart.LagerartBez COLLATE Latin1_General_CS_AS
JOIN Bestand ON Bestand.ArtGroeID = ArtGroe.ID AND Bestand.LagerArtID = Lagerart.ID;