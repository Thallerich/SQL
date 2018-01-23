DELETE FROM OPEtiKo
OUTPUT DELETED.* INTO __OPEtiKoAutoDelete
WHERE ID IN (
  SELECT OPEtiKo.ID
  FROM OPEtiKo, Artikel, ArtGru
  WHERE OPEtiKo.ArtikelID = Artikel.ID
    AND Artikel.ArtGruID = ArtGru.ID
    AND ArtGru.Steril = 1
    AND OPEtiKo.Status IN (N'A', N'D')
    AND OPEtiKo.ProduktionID = 2 --Enns
    AND CONVERT(date, OPEtiko.DruckZeitpunkt) < CONVERT(date, GETDATE())
    AND NOT EXISTS(
      SELECT OPEtiPo.*
      FROM OPEtiPo
      WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
    )
);