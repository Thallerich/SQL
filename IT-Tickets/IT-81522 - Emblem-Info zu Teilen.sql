WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, EinzHist.Barcode, Teilestatus.StatusBez AS [Status des Teils], Traeger.Traeger AS [Träger-Nr.], Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status des Trägers], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe,
  [Emblem vorhanden] = CASE WHEN EXISTS (
      SELECT TeilAppl.*
      FROM TeilAppl
      WHERE TeilAppl.EinzHistID = EinzHist.ID
        AND TeilAppl.ApplArtikelID = (SELECT Artikel.ID FROM Artikel WHERE Artikel.ArtikelNr = N'SALKDB')
    )
    THEN CAST(1 AS bit)
    ELSE CAST(0 AS bit)
  END
FROM EinzHist
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND Kunden.KdNr IN (19000, 19001, 19009, 19010, 270444, 2511145)
  AND Artikel.ArtikelNr IN (N'98XY', N'3081602001')
  AND EinzHist.[Status] IN ('A','E','G','I','K','L','M','LM','O','C','Q','S','N')
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.TraeArtiID != -1
  AND EinzHist.Archiv = 0;