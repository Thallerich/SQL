UPDATE ArtiEmb SET ArtiEmb.DruckEmblem = 1
FROM Artikel, ArtGru
WHERE ArtiEmb.ArtikelID = Artikel.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND ArtGru.ArtGruBez = N'EMBL|Patch-Emblem'
  AND ArtiEmb.DruckEmblem = 0;