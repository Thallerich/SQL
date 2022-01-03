DECLARE @curdate date = CAST(GETDATE() AS date);
DECLARE @date1weekago date = CAST(DATEADD(week, -1, GETDATE()) AS date);

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
WITH Anf AS (
  SELECT AnfKo.VsaID, KdArti.ArtikelID, MIN(AnfKo.LieferDatum) AS Lieferdatum
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  WHERE AnfKo.LieferDatum > @curdate
    AND AnfPo.Angefordert > 0
    AND AnfPo.Angefordert != AnfPo.Geliefert
    AND AnfKo.Status <= N''I''
  GROUP BY AnfKo.VsaID, KdArti.ArtikelID
)
UPDATE OPEtiKo SET PackLiefDat = Anf.Lieferdatum
FROM OPEtiKo
JOIN Anf ON Anf.ArtikelID = OPEtiKo.ArtikelID AND Anf.VsaID = OPEtiKo.PackVsaID
WHERE OPEtiKo.Status IN (N''J'', N''M'', N''P'')
  AND OPEtiKo.PackLiefDat < @date1weekago;
';

EXEC sp_executesql @sqltext, N'@curdate date, @date1weekago date', @curdate, @date1weekago;