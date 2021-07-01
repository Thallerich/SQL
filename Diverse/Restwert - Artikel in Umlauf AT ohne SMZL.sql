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
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, ArtGru.OpEinweg AS [ist OP-Einweg?], Lief.LiefNr, Lief.SuchCode AS Hauptlieferant, Lief.Name1 AS [Lieferant Adresszeile 1], CAST(COALESCE(HasSMZLAlternative.Alternative, 0) AS bit) AS [SMZL als Alternativlieferant], SUM(KdArti.Umlauf) AS [Umlaufmenge bei AT-Kunden]
FROM Artikel
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN KdArti ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
LEFT JOIN HasSMZLAlternative ON HasSMZLAlternative.ArtikelID = Artikel.ID
WHERE Lief.LiefNr != 100
  AND Artikel.Status < N'E'
  AND Firma.SuchCode = N'FA14'
  AND KdGf.KurzBez IN (N'MED', N'JOB', N'GAST', N'SAEU')
  AND KdArti.Status = N'A'
  AND Artikel.ArtiTypeID = 1
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez, Bereich.BereichBez, ArtGru.ArtGruBez, ArtGru.OpEinweg, Lief.LiefNr, Lief.SuchCode, Lief.Name1, CAST(COALESCE(HasSMZLAlternative.Alternative, 0) AS bit);