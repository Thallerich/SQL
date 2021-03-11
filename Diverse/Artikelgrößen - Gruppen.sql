WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
),
Groessenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTGROE')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], ArtGroe.Groesse, Groessenstatus.StatusBez AS [Status Größe], ArtGroe.StandardLaenge AS [Standardlänge], GroeKo.GroeKoBez AS [Größensystem], GroePo.Folge AS [Größenfolge (Sortierung)], GroePo.Gruppe
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN GroeKo ON Artikel.GroeKoID = GroeKo.ID
JOIN GroePo ON GroePo.GroeKoID = GroeKo.ID AND GroePo.Groesse = ArtGroe.Groesse
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
JOIN Groessenstatus ON ArtGroe.STatus = Groessenstatus.Status
WHERE Bereich.Bereich = N'BK'
  AND Artikel.ArtiTypeID = 1
ORDER BY Artikel.ArtikelNr, GroePo.Folge;

GO