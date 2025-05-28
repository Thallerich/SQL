DECLARE @start datetime2, @end datetime2;

SELECT
  @start = CAST($STARTDATE$ AS datetime2),
  @end = CAST(DATEADD(day, 1, $ENDDATE$) AS datetime2);

SELECT
  Code = EinzTeil.Code,
  ArtikelNr = Artikel.ArtikelNr,
  Artikelbezeichnung = Artikel.ArtikelBez$LAN$,
  Größe = ArtGroe.Groesse,
  [letzter Kunde] = Kunden.Suchcode + N' (' + CAST(Kunden.KdNr AS nvarchar) + N')',
  [letztes Auslesen] = EinzTeil.LastScanToKunde,
  [Anzahl Wäschen] = EinzTeil.RuecklaufG,
  Verrechnungsstatus = ISNULL((
    SELECT TOP 1 SoFaStatus.StatusBez$LAN$
    FROM TeilSoFa
    JOIN (SELECT [Status].[Status], [Status].StatusBez$LAN$ FROM [Status] WHERE [Status].Tabelle = N'TEILSOFA') AS SoFaStatus ON TeilSoFa.[Status] = SoFaStatus.[Status]
    WHERE TeilSoFa.EinzTeilID = EinzTeil.ID
    ORDER BY TeilSoFa.Zeitpunkt DESC
  ), N'nur Schwundgebucht'),
  [Standort-Konfiguration] = StandKon.StandKonBez$LAN$,
  Produktion = Standort.Bez
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Artikel.BereichID = StandBer.BereichID
JOIN Standort ON StandBer.ProduktionID = Standort.ID
WHERE EinzTeil.[Status] = N'W'
  AND Standort.ID IN ($2$)
  AND EinzTeil.LastScanTime BETWEEN @start AND @end;