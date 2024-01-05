DECLARE @kdnr int = 10001933;
DECLARE @lastscanbefore date = N'2023-07-24';

DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE GETDATE() BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
  WITH Teilestatus AS (
    SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
    FROM [Status]
    WHERE [Status].Tabelle = N''EINZHIST''
  )
  SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, KdArti.Variante, EinzHist.Barcode, EinzHist.RentomatChip AS Chipcode, Teilestatus.StatusBez AS [aktueller Status], EinzTeil.LastScanTime AS [letzter Scan], DATEDIFF(day, EinzTeil.LastScanTime, GETDATE()) AS [Tage seit letztem Scan],
    [Teil beim Kunden] = IIF((SELECT TOP 1 Scans.Menge FROM Scans WHERE Scans.EinzHistID = EinzHist.ID AND Scans.Menge != 0 ORDER BY Scans.ID DESC) = 1, CAST(0 AS bit), CAST(1 AS bit)),
    curRW.RestwertInfo AS [Restwert aktuell]
  FROM EinzHist
  CROSS APPLY funcGetRestwert(EinzHist.ID, @curweek, 1) curRW
  JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Kunden.KdNr = @kdnr
    AND Vsa._IsSIMBAPool = 1
    AND EinzHist.PoolFkt = 0
    AND EinzHist.[Status] BETWEEN N''Q'' AND N''W''
    AND EinzHist.[Status] != N''T''
    AND EinzHist.Einzug IS NULL
    AND EinzTeil.LastScanTime < @lastscanbefore;
';

EXEC sp_executesql @sqltext, N'@kdnr int, @curweek nchar(7), @lastscanbefore date', @kdnr, @curweek, @lastscanbefore;

SET @sqltext = N'
  SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, KdArti.Variante, SUM(IIF(EinzHist.Status = N''Q'', 1, 0)) AS [Menge Aufstocken]
  FROM EinzHist
  CROSS APPLY funcGetRestwert(EinzHist.ID, @curweek, 1) curRW
  JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Kunden.KdNr = @kdnr
    AND Vsa._IsSIMBAPool = 1
    AND EinzHist.PoolFkt = 0
    AND EinzHist.[Status] BETWEEN N''Q'' AND N''W''
    AND EinzHist.[Status] != N''T''
    AND EinzHist.Einzug IS NULL
    AND EinzTeil.LastScanTime < @lastscanbefore
  GROUP BY Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, KdArti.Variante
  HAVING SUM(IIF(EinzHist.Status = N''Q'', 1, 0)) > 0;
';

EXEC sp_executesql @sqltext, N'@kdnr int, @curweek nchar(7), @lastscanbefore date', @kdnr, @curweek, @lastscanbefore;