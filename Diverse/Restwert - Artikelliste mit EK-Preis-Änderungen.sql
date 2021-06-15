WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, Lief.LiefNr, Lief.SuchCode AS Hauptlieferant, Artikel.EkPreis AS [EK aktuell], ChgLog.Anlage_ AS [Änderungszeitpunkt], ChgLog.OldValue AS [EK alt], ChgLog.NewValue AS [EK neu]
FROM Artikel
JOIN Artikelstatus ON Artikelstatus.[Status] = Artikel.[Status]
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
LEFT JOIN ChgLog ON ChgLog.TableID = Artikel.ID AND ChgLog.TableName = N'ARTIKEL' AND ChgLog.FieldName = N'EkPreis'
WHERE Artikel.ArtiTypeID = 1
  AND Artikel.ID > 0
ORDER BY ArtikelNr, Änderungszeitpunkt DESC;

GO

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
),
ArtiVerwend AS (
  SELECT KdArti.ArtikelID, Firma.SuchCode AS Firma, COUNT(DISTINCT Kunden.ID) AS AnzKunden
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  WHERE Kunden.AdrArtID = 1
    AND KdArti.[Status] != N'I'
  GROUP BY KdArti.ArtikelID, Firma.SuchCode
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, ArtiVerwend.Firma, ArtiVerwend.AnzKunden, Lief.LiefNr, Lief.SuchCode AS Hauptlieferant, Artikel.EkPreis AS [EK aktuell]
FROM Artikel
JOIN Artikelstatus ON Artikelstatus.[Status] = Artikel.[Status]
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
LEFT JOIN ArtiVerwend ON ArtiVerwend.ArtikelID = Artikel.ID
WHERE Artikel.ArtiTypeID = 1
  AND Artikel.ID > 0
ORDER BY ArtikelNr, Firma DESC;

GO

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, Firma.SuchCode AS Firma, Lief.LiefNr, COALESCE(Lief.SuchCode, Lief.Name1) AS Lieferant, MAX(BKo.BestDat) AS [letzte Bestellung], SUM(BPo.BestMenge) AS [bestellte Menge]
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Artikelstatus ON Artikelstatus.[Status] = Artikel.[Status]
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN Lagerart ON BKo.LagerArtID = Lagerart.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
WHERE BKo.BestDat >= DATEADD(year, -1, GETDATE())
  AND BKo.Status BETWEEN N'D' AND N'M'
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Artikelstatus.StatusBez, Bereich.BereichBez, ArtGru.ArtGruBez, Firma.SuchCode, Lief.LiefNr, COALESCE(Lief.SuchCode, Lief.Name1);

GO