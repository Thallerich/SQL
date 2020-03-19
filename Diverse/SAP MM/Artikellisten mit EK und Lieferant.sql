SELECT DISTINCT Artikel.ArtikelNr, Lief.LiefNr, CAST(IIF(ArtiLief.LiefID = Artikel.LiefID, 1, 0) AS bit) AS Hauptlieferant, ArtGru.Gruppe AS Warengruppe
FROM Artikel
JOIN ArtiLief ON ArtiLief.ArtikelID = Artikel.ID
JOIN Lief ON ArtiLief.LiefID = Lief.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE Artikel.ArtikelNr IS NOT NULL
ORDER BY ArtikelNr ASC, Hauptlieferant DESC;

SELECT Artikel.ArtikelNr, NULL AS Groesse, Lief.LiefNr, CAST(IIF(ArtiLief.LiefID = Artikel.LiefID, 1, 0) AS bit) AS Hauptlieferant, IIF(ArtiLief.EkPreis != 0, ArtiLief.EkPreis, Artikel.EkPreis) AS EKPreis, IIF(ArtiLief.EkPreis != 0, ArtiLief.EkPreisSeit, Artikel.EkPreisSeit) AS [Gültig ab], NULL AS Zuschlag, ArtGru.Gruppe AS Warengruppe, Bereich.Bereich AS Produktbereich
FROM Artikel
JOIN ArtiLief ON ArtiLief.ArtikelID = Artikel.ID
JOIN Lief ON ArtiLief.LiefID = Lief.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE Artikel.ArtikelNr IS NOT NULL
  AND NOT EXISTS (
    SELECT ArtGroe.*
    FROM ArtGroe
    WHERE ArtGroe.ArtikelID = Artikel.ID
  )

UNION ALL

SELECT Artikel.ArtikelNr, ArtGroe.Groesse, Lief.LiefNr, CAST(IIF(ArtiLief.LiefID = Artikel.LiefID, 1, 0) AS bit) AS Hauptlieferant, IIF(ArtiLief.EkPreis != 0, ArtiLief.EkPreis, Artikel.EkPreis) AS EKPreis, IIF(ArtiLief.EkPreis != 0, ArtiLief.EkPreisSeit, Artikel.EkPreisSeit) AS [Gültig ab], ArtGroe.Zuschlag AS [Zuschlag %], ArtGru.Gruppe AS Warengruppe, Bereich.Bereich AS Produktbereich
FROM Artikel
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
JOIN ArtiLief ON ArtiLief.ArtGroeID = ArtGroe.ID
JOIN Lief ON ArtiLief.LiefID = Lief.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE Artikel.ArtikelNr IS NOT NULL
ORDER BY ArtikelNr ASC, Groesse ASC, Hauptlieferant DESC;