WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], ArtGroe.Groesse AS Größe, COUNT(EinzTeil.ID) AS [Bestand gesamt], SUM(IIF(EinzTeil.AnzWasch <= 1, 1, 0)) AS [Bestand neu], SUM(IIF(EinzTeil.AnzWasch > 1, 1, 0)) AS [Bestand gebraucht]
FROM EinzTeil
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN Artikelstatus ON Artikelstatus.[Status] = Artikel.[Status]
WHERE EinzTeil.ZielNrID = 100070077
  AND EinzTeil.Status IN (N'A', N'Q')
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez, ArtGroe.Groesse, GroePo.Folge
ORDER BY ArtikelNr, GroePo.Folge;