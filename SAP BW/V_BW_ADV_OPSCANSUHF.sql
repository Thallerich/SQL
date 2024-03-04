CREATE OR ALTER VIEW sapbw.V_BW_ADV_OPSCANSUHF AS
  SELECT EinzTeil.ID AS Chipcode, /* (Code wird als Textfeld gesondert geladen... - WTF?) */
    ArtikelNr = UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)),
    Auslesezeitpunkt = Poolscan.Zeitpunkt,
    Auslesedatum = CAST(Poolscan.Zeitpunkt AS date),
    Einlesezeitpunkt = Poolscan.NextZeitpunkt,
    Einlesedatum = CAST(Poolscan.NextZeitpunkt AS date),
    Vsa.VsaNr,
    Kunden.KdNr
  FROM Salesianer.dbo.EinzTeil
  JOIN Salesianer.dbo.ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
  JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN (
    SELECT Scans.EinzTeilID, Scans.[DateTime] AS Zeitpunkt, LEAD(Scans.[DateTime]) OVER (PARTITION BY Scans.EinzTeilID ORDER BY Scans.ID ASC) AS NextZeitpunkt, Scans.AnfPoID, AnfKo.VsaID
    FROM Salesianer.dbo.Scans
    JOIN Salesianer.dbo.AnfPo ON Scans.AnfPoID = AnfPo.ID
    JOIN Salesianer.dbo.AnfKo ON AnfPo.AnfKoID = AnfKo.ID
    WHERE Scans.EinzTeilID > 0  /* nur Poolteile */
      AND Scans.Menge != 0
      AND Scans.ActionsID IN (1, 100, 2, 102)
      AND Scans.[DateTime] >= N'2022-01-01 00:00:00'
  ) AS Poolscan ON Poolscan.EinzTeilID = EinzTeil.ID
  JOIN Salesianer.dbo.Vsa ON Poolscan.VsaID = Vsa.ID
  JOIN Salesianer.dbo.Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Poolscan.AnfPoID > 0;

GO