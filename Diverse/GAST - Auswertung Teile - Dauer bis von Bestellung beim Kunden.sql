WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Teilestatus.[StatusBez] AS [Status des Teils], CAST(Teile.Anlage_ AS date) AS Erfassungsdatum, IIF(Teile.PatchDatum < N'2000-01-01', NULL, Teile.PatchDatum) AS Patchdatum, IIF(Teile.IndienstDat < N'2000-01-01', NULL, Teile.IndienstDat) AS Indienststellungsdatum
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
WHERE Kunden.KdNr = 30480
  AND Teile.Status BETWEEN N'E' AND N'W'
  AND Teile.Einzug IS NULL
ORDER BY Teile.Anlage_ DESC;