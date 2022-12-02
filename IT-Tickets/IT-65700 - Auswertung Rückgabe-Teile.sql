DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE GETDATE() BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
WITH EinzHistStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N''EINZHIST''
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Traeger.Traeger AS TrägerNr, Traeger.PersNr AS Personalnummer, Traeger.Vorname, Traeger.Nachname, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, EinzHist.Barcode, EinzHistStatus.StatusBez AS Teilestatus, EinzHist.AbmeldDat AS [Datum Abmeldung], EinzHist.AlterInfo AS [Alter in Wochen], KdArti.BasisRestwert AS [Basis-Restwert], fRW.RestwertInfo [Restwert KW ' + @curweek + N']
FROM EinzHist
CROSS APPLY funcGetRestwert(EinzHist.ID, @CurWeek, 1) AS fRW
JOIN EinzHistStatus ON EinzHist.[Status] = EinzHistStatus.[Status]
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
/* JOIN Holding ON Kunden.HoldingID = Holding.ID */  /* nur falls über ganze Holding */
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
WHERE Kunden.KdNr = 272295 /* Holding.Holding = N''VOES'' */
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.[Status] IN (N''U'', N''W'')
  AND EinzHist.Einzug IS NULL
  AND EinzHist.AbmeldDat < DATEADD(week, -3, GETDATE());
';

EXEC sp_executesql @sqltext, N'@curweek nchar(7)', @curweek;