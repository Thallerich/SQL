WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Bereich.Bereich, Bereich.BereichBez AS Bereichsbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez AS Artikelstatus, ArtiType.ArtiTypeBez AS Artikeltyp, Lief.LiefNr AS HauptlieferantNr, Lief.SuchCode AS Hauptlieferant
FROM Artikel
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtiType ON Artikel.ArtiTypeID = ArtiType.ID
WHERE Artikel.ID > 0