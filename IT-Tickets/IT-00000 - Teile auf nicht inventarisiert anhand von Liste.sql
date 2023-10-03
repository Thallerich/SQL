UPDATE EinzHist SET Inventarisiert = 1
WHERE ID IN (
    SELECT EinzHist.ID
    FROM EinzHist
    JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
    JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
    JOIN LagerOrt ON EinzHist.LagerortID = Lagerort.ID
    WHERE EinzHist.EinzHistTyp = 2
      AND EinzHist.[Status] < 'XM'
      AND EinzHist.ID > - 1
      AND EinzHist.LagerArtID = 14557
  )
  AND Inventarisiert = 0;

GO

UPDATE EinzHist SET Inventarisiert = 0
WHERE ID IN (
    SELECT EinzHist.ID
    FROM EinzHist
    JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
    JOIN Lagerort ON EinzHist.LagerortID = Lagerort.ID
    JOIN Standort ON Lagerart.LagerID = Standort.ID
    JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
    JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
    JOIN Salesianer.dbo._LagInvEnnsDelete ON Standort.Bez = _LagInvEnnsDelete.Lagerstandort COLLATE Latin1_General_CS_AS
      AND Lagerort.Lagerort = _LagInvEnnsDelete.Lagerort COLLATE Latin1_General_CS_AS
      AND Lagerart.LagerartBez = _LagInvEnnsDelete.Lagerart COLLATE Latin1_General_CS_AS
      AND ArtGroe.Groesse = _LagInvEnnsDelete.Groesse COLLATE Latin1_General_CS_AS
      AND Artikel.ArtikelNr = _LagInvEnnsDelete.ArtikelNr COLLATE Latin1_General_CS_AS
    WHERE EinzHist.EinzHistTyp = 2
      AND EinzHist.[Status] < N'XM'
      AND EinzHist.ID > 0
      AND Lagerart.LagerartBez = N'Enns (JOB) BK Gebraucht'
  )
  AND Inventarisiert = 1;

GO