/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ getData                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Result281;

CREATE TABLE #Result281 (
  [Letzter Scan] datetime2,
  [Letztes Ziel] nvarchar(60),
  EinzHistID int,
  KdNr int,
  Name2 nvarchar(40),
  Name3 nvarchar(40),
  Kunde nvarchar(40),
  Seriennummer nvarchar(33),
  Artikel nvarchar(60),
  [Status] nchar(2),
  Eingang1 date,
  Ausgang1 date,
  Träger nvarchar(61),
  ZimmerNr nvarchar(10),
  SuchCode nvarchar(40),
  Bez nvarchar(40),
  Vsa nvarchar(40),
  Vsa2 nvarchar(40),
  Vsa3 nvarchar(40),
  Fach int
);

DECLARE @sqltext nvarchar(max),
  @kundenid int,
  @maxscantime datetime;

SET @kundenid = $1$;
SET @maxscantime = $2$;

SET @sqltext = N'
  SELECT MAX(Scans.[DateTime]) AS [Letzter Scan], (
    SELECT TOP 1 ZielNr.ZielNrBez$LAN$
      FROM ZielNr, Scans
      WHERE Scans.ZielNrID = ZielNr.ID
        AND Scans.EinzHistID = a.EinzHistID
      ORDER BY Scans.[DateTime] DESC
    ) AS [Letztes Ziel], a.*
  FROM (
    SELECT EinzHist.ID AS EinzHistID, Kunden.KdNr, Kunden.Name2, Kunden.Name3, Kunden.Name1 AS Kunde, EinzHist.Barcode AS Seriennummer, Artikel.ArtikelBez$LAN$ AS Artikel, EinzHist.Status, EinzHist.Eingang1, EinzHist.Ausgang1, ISNULL(RTRIM(Traeger.Nachname), '''') + '' '' + ISNULL(RTRIM(Traeger.Vorname), '''') AS Träger, Traeger.PersNr AS ZimmerNr, VSA.SuchCode, VSA.Bez AS Bez, VSA.Name1 AS Vsa, VSA.Name2 AS VSA2, VSA.Name3 AS VSA3, (SELECT TOP 1 Fach FROM ScanFach WHERE ScanFach.VsaID = Vsa.ID AND ScanFach.TraegerID = Traeger.ID) AS Fach
    FROM EinzHist
    JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
    JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
    WHERE Kunden.ID = @kundenid
      AND EinzHist.Eingang1 IS NOT NULL
      AND (EinzHist.Eingang1 > EinzHist.Ausgang1 OR EinzHist.Ausgang1 IS NULL)
      AND EinzHist.Status BETWEEN N''M'' AND N''Q''
      AND EinzTeil.AltenheimModus > 0
      AND Traeger.Status != N''I''
    ) a, Scans
  WHERE a.EinzHistID = Scans.EinzHistID
    AND Scans.AnlageUserID_ <> (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N''ADVSUP'')
  GROUP BY a.EinzHistID, KdNr, Name2, Name3, Kunde, Seriennummer, Artikel, Status, Eingang1, Ausgang1, Träger, ZimmerNr, SuchCode, Bez, Vsa, Vsa2, Vsa3, Fach
  HAVING MAX(CONVERT(date, [DateTime])) <= @maxscantime
  ORDER BY SuchCode, Träger;
';

INSERT INTO #Result281 ([Letzter Scan], [Letztes Ziel], EinzHistID, KdNr, Name2, Name3, Kunde, Seriennummer, Artikel, [Status], Eingang1, Ausgang1, Träger, ZimmerNr, SuchCode, Bez, Vsa, Vsa2, Vsa3, Fach)
EXEC sp_executesql @sqltext, N'@kundenid int, @maxscantime datetime', @kundenid, @maxscantime;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile                                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT "Letzter Scan", "Letztes Ziel", EinzHistID, KdNr, Name2, Name3, Kunde, Seriennummer, Artikel, Status, Eingang1, Ausgang1, Träger, ZimmerNr, SuchCode, Bez, Vsa, Vsa2, Vsa3, Fach
FROM #Result281;