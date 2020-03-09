WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT IIF(ISNULL(Teile.Eingang1, N'1980-01-01') > ISNULL(Teile.Ausgang1, N'2099-12-31'), N'R', N'') AS Rueck,
  Teilestatus.StatusBez AS [Status],
  Teile.Barcode,
  Hinweis.Hinweis,
  Hinweis.EingabeDatum,
  Traeger.Traeger,
  RTRIM(ISNULL(Traeger.Nachname, N'')) + N' ' + RTRIM(ISNULL(Traeger.Vorname, N'')) AS Träger,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  IIF(ISNULL(Teile.Eingang1, N'1980-01-01') < ISNULL(Teile.Ausgang1, N'2099-12-31'),1, 0) AS Ist,
  TraeArti.Menge AS Soll,
  Teile.RuecklaufK AS Waschzyklen,
  Fach = (
    SELECT TOP 1 TraeFach.Fach
    FROM TraeFach
    WHERE TraeFach.TraegerID = Traeger.ID
  ),
  Schrank = (
    SELECT TOP 1 Schrank.SchrankNr
    FROM TraeFach
    JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
    WHERE TraeFach.TraegerID = Traeger.ID
  ),
  Teile.Indienst,
  Teile.Ausdienst,
  Teile.Ausgang1,
  Teile.Eingang1,
  Kunden.ID AS KundenID
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teilestatus.[Status] = Teile.[Status]
LEFT OUTER JOIN Hinweis ON Hinweis.TeileID = Teile.ID AND Hinweis.Aktiv = 1
WHERE Traeger.ID = $ID$
ORDER BY Artikel.ArtikelNr ASC;