WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
),
HasSMZLAlternative AS (
  SELECT ArtiLief.ArtikelID, CAST(1 AS bit) AS Alternative
  FROM ArtiLief
  WHERE ArtiLief.LiefID = (SELECT ID FROM Lief WHERE LiefNr = 100)
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez AS Produktbereich, Lief.LiefNr, Lief.SuchCode AS Hauptlieferant, Lief.Name1 AS [Lieferant Adresszeile 1], CAST(COALESCE(HasSMZLAlternative.Alternative, 0) AS bit) AS [SMZL als Alternativlieferant]
FROM Artikel
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Lief ON Artikel.LiefID = Lief.ID
LEFT JOIN HasSMZLAlternative ON HasSMZLAlternative.ArtikelID = Artikel.ID
WHERE Lief.LiefNr != 100
  AND Artikel.Status < N'E'
  AND EXISTS (
    SELECT KdArti.*
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN Firma ON Kunden.FirmaID = Firma.ID
    WHERE KdArti.ArtikelID = Artikel.ID
      AND Firma.SuchCode = N'FA14'
      AND KdArti.Status = N'A'
      AND KdArti.Umlauf > 0
  );