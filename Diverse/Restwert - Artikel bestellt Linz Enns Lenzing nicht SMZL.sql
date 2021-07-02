WITH ArtiSMZL AS (
  SELECT Artikel.ID AS ArtikelID, CAST(1 AS bit) AS HasSMZL
  FROM Artikel
  WHERE Artikel.LiefID = (SELECT ID FROM Lief WHERE LiefNr = 100)
), 
Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, ArtGru.OPEinweg AS [ist OP-Einweg?], Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez AS [Status des Artikels], Lief.LiefNr, Lief.SuchCode AS Lieferant, Lief.Name1 AS [Lieferant Adresszeile 1], Lager.Bez AS Lagerstandort, MAX(BKo.Datum) AS [Datum letzte Bestellung], COUNT(BKo.ID) AS [Anzahl Bestellungen seit 2021-01-01], COALESCE(ArtiSMZL.HasSMZL, 0) AS [SMZL als Hauptlieferant]
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Lagerart ON BKo.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Lief ON BKo.LiefID = Lief.ID
LEFT JOIN ArtiSMZL ON ArtiSMZL.ArtikelID = Artikel.ID
WHERE BKo.Datum >= N'2021-01-01'
  AND BKo.Status BETWEEN N'F' AND N'M'
  --AND (Lager.SuchCode LIKE N'WOL_' OR Lager.SuchCode LIKE N'WOE_' OR Lager.SuchCode LIKE N'UKL_')
  AND Lager.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND Lief.LiefNr != 100
GROUP BY Bereich.BereichBez, ArtGru.ArtGruBez, ArtGru.OPEinweg, Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez, Lief.LiefNr, Lief.SuchCode, Lief.Name1, Lager.Bez, COALESCE(ArtiSMZL.HasSMZL, 0)
ORDER BY ArtikelNr ASC, LiefNr ASC;