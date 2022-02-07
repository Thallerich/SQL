DECLARE @curdate date = CAST(GETDATE() AS date);
DECLARE @date1dayago date = CAST(DATEADD(day, -1, GETDATE()) AS date);
DECLARE @verfalldays int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = N'OP_ZU_PACKZETTEL_VOR_ABLAUF');

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
UPDATE OPEtiKo SET PackLiefDat = ISNULL(Anf.Lieferdatum, DATEADD(day, 1, CAST(GETDATE() AS date)))
FROM OPEtiKo
LEFT JOIN Anf ON Anf.ArtikelID = OPEtiKo.ArtikelID AND Anf.VsaID = OPEtiKo.PackVsaID
WHERE OPEtiKo.Status IN (N''J'', N''M'', N''P'')
  AND OPEtiKo.PackLiefDat < @date1dayago
  AND OPEtiKo.Verfalldatum < DATEADD(day, @verfalldays * -1, @curdate);
';

EXEC sp_executesql @sqltext, N'@curdate date, @date1dayago date, @verfalldays int', @curdate, @date1dayago, @verfalldays;