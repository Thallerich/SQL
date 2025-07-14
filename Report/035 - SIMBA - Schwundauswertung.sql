/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Prepare Data                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Schwundteile;

DECLARE @kundenid int = $ID$;
DECLARE @lastscanbefore date = $1$;

DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE GETDATE() BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @sqltext nvarchar(max);

CREATE TABLE #Schwundteile (
  Holding nvarchar(10) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  VsaNr int,
  VsaBez nvarchar(40) COLLATE Latin1_General_CS_AS,
  Traeger varchar(8) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(40) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Größe nvarchar(12) COLLATE Latin1_General_CS_AS,
  Variante nvarchar(4) COLLATE Latin1_General_CS_AS,
  Barcode varchar(33) COLLATE Latin1_General_CS_AS,
  Chipcode varchar(33) COLLATE Latin1_General_CS_AS,
  [aktueller Status] nvarchar(40) COLLATE Latin1_General_CS_AS,
  [letzte Aktion] nvarchar(60) COLLATE Latin1_General_CS_AS,
  [letzter Scan] datetime2,
  [Tage seit letztem Scan] int,
  [Teil beim Kunden] bit,
  [Restwert aktuell] money,
  EinzHistStatus varchar(2) COLLATE Latin1_General_CS_AS
);

SET @sqltext = N'
  WITH Teilestatus AS (
    SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
    FROM [Status]
    WHERE [Status].Tabelle = N''EINZHIST''
  )
  INSERT INTO #Schwundteile (Holding, KdNr, Kunde, VsaNr, VsaBez, Traeger, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Größe, Variante, Barcode, Chipcode, [aktueller Status], [letzte Aktion], [letzter Scan], [Tage seit letztem Scan], [Teil beim Kunden], [Restwert aktuell], EinzHistStatus)
  SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, KdArti.Variante, EinzHist.Barcode, EinzHist.RentomatChip AS Chipcode, Teilestatus.StatusBez AS [aktueller Status], Actions.ActionsBez AS [letzte Aktion], EinzTeil.LastScanTime AS [letzter Scan], DATEDIFF(day, EinzTeil.LastScanTime, GETDATE()) AS [Tage seit letztem Scan],
    [Teil beim Kunden] = IIF((SELECT TOP 1 Scans.Menge FROM Scans WHERE Scans.EinzHistID = EinzHist.ID AND Scans.Menge != 0 AND NOT EXISTS (SELECT s.* FROM Scans AS s WHERE s.EinzHistID = Scans.EinzHistID AND s.[DateTime] > Scans.[DateTime] AND s.ZielNrID NOT IN (SELECT SdcZiel.ZielNrID FROM SdcZiel WHERE SdcZiel.ZielNrID > 0) AND s.ActionsID NOT IN (2 ,102 ,120 ,129 ,130 ,136 ,137 ,154 ,173)) ORDER BY Scans.ID DESC) = -1, CAST(1 AS bit), CAST(0 AS bit)),
    curRW.RestwertInfo AS [Restwert aktuell], EinzHist.Status AS EinzHistStatus
  FROM EinzHist
  CROSS APPLY funcGetRestwert(EinzHist.ID, @curweek, 1) curRW
  JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
  JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Kunden.ID = @kundenid
    AND Vsa._IsSIMBAPool = 1
    AND EinzHist.PoolFkt = 0
    AND EinzHist.[Status] BETWEEN N''Q'' AND N''W''
    AND EinzHist.[Status] != N''T''
    AND EinzHist.Einzug IS NULL
    AND EinzTeil.LastScanTime < @lastscanbefore;
';

EXEC sp_executesql @sqltext, N'@kundenid int, @curweek nchar(7), @lastscanbefore date', @kundenid, @curweek, @lastscanbefore;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Schwundteile                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Holding, KdNr, Kunde, VsaNr, VsaBez, Traeger, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Größe, Variante, Barcode, Chipcode, [aktueller Status], [letzte Aktion], [letzter Scan], [Tage seit letztem Scan], [Teil beim Kunden], [Restwert aktuell]
FROM #Schwundteile;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Aufzustocken                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Holding, KdNr, Kunde, VsaNr, VsaBez, Traeger, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Größe, Variante, SUM(IIF(EinzHistStatus = N'Q', 1, 0)) AS [Menge Aufstocken]
FROM #Schwundteile
GROUP BY Holding, KdNr, Kunde, VsaNr, VsaBez, Traeger, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Größe, Variante
HAVING SUM(IIF(EinzHistStatus = N'Q', 1, 0)) > 0;