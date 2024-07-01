WITH Trägerstatus AS  (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Versandanschrift, Traeger.Traeger AS TrägerNr, Traeger.PersNr AS Personalnummer, Traeger.Vorname, Traeger.Nachname, Trägerstatus.StatusBez AS Trägerstatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, IIF(EinzHist.Status < N'M', N'<<unbekannt>>', EinzHist.Barcode) AS Barcode,
  [Status] = CASE
    WHEN EinzHist.[Status] < N'Q' THEN N'noch offen'
    WHEN EinzHist.[Status] IN (N'U', N'W') THEN N'Rückgabeteile'
    WHEN EinzHist.[Status] IN (N'S') THEN N'Austauschteile'
    ELSE N'<<unknown>>'
  END
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Trägerstatus ON Traeger.[Status] = Trägerstatus.[Status]
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
WHERE Kunden.ID = $1$
  AND EinzHist.[Status] BETWEEN N'E' AND N'W'
  AND EinzHist.[Status] != N'Q'
  AND EinzHist.[Status] != N'T'
  AND EinzHist.Einzug IS NULL
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
  AND EinzTeil.AltenheimModus = 0;