DECLARE @HoldingID int = $1$;
DECLARE @Stichtag date = $2$;
DECLARE @LanguageID int = (SELECT MainLanguageID FROM #AdvSession);
DECLARE @Lang nchar(2) = (SELECT SysLanguage FROM advFunc_LanguageIDToSysLanguage(@LanguageID));
DECLARE @Woche nchar(7);
DECLARE @sqltext nvarchar(max);

SET @Woche = (SELECT Week.Woche FROM Week WHERE @Stichtag BETWEEN Week.vonDat AND Week.BisDat);

SET @sqltext = N'
SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [VSA-Bezeichnung],
  Traeger.Traeger AS TrägerNr,
  Traeger.Vorname,
  Traeger.Nachname,
  Abteil.Abteilung AS KsSt,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez' + @Lang + ' AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  Artikel.EKPreis,
  EinzHist.Barcode,
  EinzHist.Eingang1 AS [letzter Eingang],
  EinzHist.Ausgang1 AS [letzter Ausgang],
  EinzHist.Indienst AS [Indienststellungswoche],
  EinzHist.Ausdienst AS [Abmeldungswoche],
  Week.Woche AS [Ersteinsatzwoche],
  fRW.RestwertInfo AS [Restwert ' + FORMAT(@Stichtag, N'dd.MM.yyyy', N'de-AT') + '],
  DATEDIFF(day, ISNULL(EinzHist.Ausgang1, GETDATE()), GETDATE()) AS BeimKundeSeitTagen
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Week ON DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
CROSS APPLY funcGetRestwert(EinzHist.ID, N''' + @Woche + ''', 1) AS fRW
WHERE Holding.ID = ' + CAST(@HoldingID AS nvarchar) + '
  AND Artikel.Status != N''B''
  AND (EinzHist.Ausdienst = N'''' OR EinzHist.Ausdienst IS NULL)
  AND EinzHist.Status BETWEEN N''Q'' AND N''W''
  AND EinzHist.Einzug IS NULL
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND Traeger.Altenheim = 0;
';

EXEC sp_executesql @sqltext;