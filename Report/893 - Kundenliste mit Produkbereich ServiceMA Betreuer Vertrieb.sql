DROP TABLE IF EXISTS #ResultSet893;

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
),
Vertragstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VERTRAG'
),
WebInfo AS (
  SELECT WebUser.KundenID, COUNT(WebUser.ID) AS AnzAktiveUser, LetzterLoginIrgendeinUser = (
    SELECT MAX(WebLogin.Zeitpunkt)
    FROM WebLogin
    JOIN WebUser AS wu ON WebLogin.UserName = wu.UserName
    WHERE wu.KundenID = WebUser.KundenID
      AND WebLogin.Success = 1
      AND WebLogin.IsLogout = 0
  )
  FROM WebUser
  WHERE WebUser.[Status] = N'A'
  GROUP BY WebUser.KundenID
)
SELECT Firma.Bez AS Firma,
  KdGf.KurzBez AS Geschäftsbereich,
  [Zone].ZonenCode AS Vertriebszone,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1 AS [Adresszeile 1],
  Kunden.Name2 AS [Adresszeile 2],
  Kunden.Name3 AS [Adresszeile 3],
  Kunden.Strasse,
  Kunden.Land,
  Kunden.PLZ,
  Kunden.Ort,
  Kundenstatus.StatusBez AS Kundenstatus,
  Standort.Bez AS Hauptstandort,
  Sichtbar.Bez AS Sichtbarkeit,
  ABC.ABCBez$LAN$ AS [ABC-Klasse],
  Kunden.UStIdNr,
  BrLauf.BrLaufBez$LAN$ AS Bearbeitungsrechnungslauf,
  Bereich.BereichBez$LAN$ AS Produktbereich,
  FakFreq.FakFreqBez$LAN$ AS Fakturafrequenz,
  Adressgruppe = STUFF((
    SELECT N', ' + AdrGrp.AdrGrpBez + N' (' + AdrGrp.Nr + N')'
    FROM KdGru
    JOIN AdrGrp ON KdGru.AdrGrpID = AdrGrp.ID
    WHERE KdGru.KundenID = Kunden.ID
    ORDER BY AdrGrp.Nr ASC
    FOR XML PATH(N'')
  ), 1, 2, N''),
  ISNULL(ServiceKdBer.Nachname + N', ', N'') + ISNULL(ServiceKdBer.Vorname, N'') AS [Kundenservice],
  ISNULL(BetreuerKdBer.Nachname + N', ', N'') + ISNULL(BetreuerKdBer.Vorname, N'') AS [Kundenbetreuer],
  ISNULL(VertriebKdBer.Nachname + N', ', N'') + ISNULL(VertriebKdBer.Vorname, N'') AS [Vertrieb],
  [Anzahl VSAs] = (
    SELECT COUNT(Vsa.ID)
    FROM Vsa
    WHERE Vsa.KundenID = Kunden.ID
      AND Vsa.[Status] = N'A'
  ),
  [Anzahl aktive Träger] = (
    SELECT COUNT(Traeger.ID)
    FROM Traeger
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    WHERE Vsa.KundenID = Kunden.ID
      AND Traeger.[Status] != N'I'
      AND Traeger.Altenheim = 0
  ),
  [Anzahl kundeneigene Teile] = (
    SELECT COUNT(EinzHist.ID)
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzHist.KundenID = Kunden.ID
      AND EinzHist.PoolFkt = 0
      AND EinzHist.EinzHistTyp = 1
      AND EinzTeil.AltenheimModus = 0
      AND EinzHist.[Status] = N'Z'
  ),
  [Bereich-Jahresumsatz netto] = (
    SELECT SUM(RechPo.GPreis)
    FROM RechPo
    JOIN RechKo ON RechPo.RechKoID = RechKo.ID
    WHERE RechKo.KundenID = Kunden.ID
      AND RechPo.KdBerID = KdBer.ID
      AND RechKo.RechDat >= CAST(DATEADD(year, -1, DATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1, 0, 0, 0, 0)) AS date)
  ),
  RechWae.IsoCode AS Rechnungswährung,
  Vertrag.VertragLfdNr AS [Laufende Nr. Vertrag],
  Vertragstatus.StatusBez AS [Status Vertrag],
  Vertrag.VertragAbschluss AS [Abschluss-Datum],
  Vertrag.VertragStart AS [Start-Datum],
  Vertrag.VertragEndeMoegl AS [nächstmögliches Ende],
  Vertrag.VertragEnde AS [reguläres Ende],
  Vertrag.VertragKuendZum AS [Kündigung zum],
  Vertrag.VertragLetzteAnl AS [nicht mehr beliefern ab],
  Vertrag.LetztePeDatum AS [letzte Preiserhöhung am],
  Vertrag.LetztePeProz AS [letzte Preiserhöhung Prozentsatz],
  PrLauf.Code + N' - ' + PrLauf.PrLaufBez$LAN$ AS Preiserhöhungslauf,
  RwConfig.RwConfigBez$LAN$ AS [Restwertkonfiguration BK],
  CAST(IIF(WebInfo.AnzAktiveUser IS NOT NULL, 1, 0) AS bit) AS [Webportal-Zugriff],
  WebInfo.AnzAktiveUser AS [Anzahl aktive Webportal-Benutzer],
  WebInfo.LetzterLoginIrgendeinUser AS [Letzter Webportal-Login]
INTO #ResultSet893
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN KdBer oN KdBer.KundenID = Kunden.ID
JOIN Mitarbei AS BetreuerKdBer ON KdBer.BetreuerID = BetreuerKdBer.ID
JOIN Mitarbei AS VertriebKdBer ON KdBer.VertreterID = VertriebKdBer.ID
JOIN Mitarbei AS ServiceKdBer ON KdBer.ServiceID = ServiceKdBer.ID
JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kundenstatus ON Kundenstatus.Status = Kunden.Status
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Sichtbar ON Kunden.SichtbarID = Sichtbar.ID
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
JOIN Vertragstatus ON Vertrag.[Status] = Vertragstatus.[Status]
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
JOIN RwConfig ON Kunden.RWConfigID = RwConfig.ID
JOIN BrLauf ON Kunden.BRLaufID = BrLauf.ID
JOIN Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
LEFT JOIN WebInfo ON WebInfo.KundenID = Kunden.ID
WHERE Kundenstatus.ID IN ($4$)
  AND Kunden.AdrArtID = 1
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND [Zone].ID IN ($3$)
  AND Kunden.StandortID IN ($5$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND (($6$ = 1 AND Vertrag.VertragKuendZum >= CAST(GETDATE() AS date)) OR ($6$ = 0));

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT *
FROM #ResultSet893;