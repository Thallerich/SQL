/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-94385                                                                                                                  ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2025-06-13                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT
  Kunden.KdNr,
  Kunde = Kunden.SuchCode,
  Vsa.VsaNr,
  [Vsa-Bezeichnung] = Vsa.Bez,
  [Träger-Nr] = Traeger.Traeger,
  Traeger.Vorname,
  Traeger.Nachname,
  Artikel.ArtikelNr,
  Artikelbezeichnung = Artikel.ArtikelBez$LAN$,
  Größe = ArtGroe.Groesse,
  Barcode = EinzTeil.Code,
  [Status] = Teilstatus.StatusBez,
  [Datum Restwert-Verkauf] = CAST(MAX(TeilSoFa.Zeitpunkt) AS date),
  Preis = TeilSoFa.EPreis,
  Preis_WaeID = Kunden.VertragWaeID,
  [letzter Ausgang] = MAX(EinzHist.Ausgang1),
  [letzter Eingang nach Verkauf] = (SELECT TOP 1 Scans.[DateTime] FROM Scans WHERE Scans.EinzTeilID = EinzHist.EinzTeilID AND Scans.[DateTime] > MAX(TeilSoFa.Zeitpunkt) AND Scans.Menge = 1 ORDER BY Scans.[DateTime] DESC)
FROM TeilSoFa
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
) AS Teilstatus ON EinzHist.[Status] = Teilstatus.[Status]
WHERE TeilSoFa.SoFaArt = N'R'
  AND TeilSoFa.[Status] > N'D'
  AND EinzTeil.[Status] = N'Z'
  AND EinzTeil.AltenheimModus = 0
  AND EinzHist.[Status] IN (N'Z', N'Y')
  AND EinzHist.PoolFkt = 0
  AND EXISTS (
    SELECT 1
    FROM Scans
    WHERE Scans.EinzTeilID = EinzHist.EinzTeilID
      AND Scans.[DateTime] > TeilSoFa.Zeitpunkt
      AND Scans.Menge = 1
  )
  AND TeilSoFa.Zeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.ID IN ($6$)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, EinzTeil.Code, Teilstatus.StatusBez, TeilSoFa.EPreis, Kunden.VertragWaeID, EinzHist.EinzTeilID;