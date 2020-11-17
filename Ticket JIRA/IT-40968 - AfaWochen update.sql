DECLARE @AfaChanged TABLE (
  KundenID int,
  ArtikelID int,
  Variante nchar(2),
  VariantBez nvarchar(60),
  AfaWochen int
);

UPDATE KdArti SET AfaWochen = 208
OUTPUT inserted.KundenID, inserted.ArtikelID, inserted.Variante, inserted.VariantBez, deleted.AfaWochen
INTO @AfaChanged
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.KdNr IN (6020, 19000, 19001, 19009, 19010, 19011, 19012, 19030, 2511145)
  AND Bereich.Bereich = N'BK'
  AND KdArti.AfaWochen != 208;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez, AfaChanged.Variante, AfaChanged.VariantBez AS Variantenbezeichnung, AfaChanged.AfaWochen AS [AfaWochen bisher], 208 AS [AfaWochen neu]
FROM @AfaChanged AS AfaChanged
JOIN Kunden ON AfaChanged.KundenID = Kunden.ID
JOIN Artikel ON AfaChanged.ArtikelID = Artikel.ID;