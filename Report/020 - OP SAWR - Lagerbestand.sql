WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], ArtGroe.Groesse AS Größe, COUNT(OPTeile.ID) AS Bestand
FROM OPTeile
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN Artikelstatus ON Artikelstatus.[Status] = Artikel.[Status]
WHERE OPTeile.ZielNrID = 100070077
  AND OPTeile.Status IN (N'A', N'Q')
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez, ArtGroe.Groesse, GroePo.Folge
ORDER BY ArtikelNr, GroePo.Folge;