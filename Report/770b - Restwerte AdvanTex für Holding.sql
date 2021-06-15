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
  Teile.Barcode,
  Teile.Eingang1 AS [letzter Eingang],
  Teile.Ausgang1 AS [letzter Ausgang],
  Teile.Indienst AS [Indienststellungswoche],
  Teile.Ausdienst AS [Abmeldungswoche],
  Week.Woche AS [Ersteinsatzwoche],
  fRW.RestwertInfo AS [Restwert ' + FORMAT(@Stichtag, N'dd.MM.yyyy', N'de-AT') + '],
  DATEDIFF(day, ISNULL(Teile.Ausgang1, GETDATE()), GETDATE()) AS BeimKundeSeitTagen
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
CROSS APPLY funcGetRestwert(Teile.ID, N''' + @Woche + ''', 1) AS fRW
WHERE Holding.ID = ' + CAST(@HoldingID AS nvarchar) + '
  AND Artikel.Status != N''B''
  AND (Teile.Ausdienst = N'''' OR Teile.Ausdienst IS NULL)
  AND Teile.Status BETWEEN N''Q'' AND N''W''
  AND Teile.Einzug IS NULL
  AND Traeger.Altenheim = 0;
';

EXEC sp_executesql @sqltext;