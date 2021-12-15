DECLARE @curdate date = CAST(GETDATE() AS date);
DECLARE @date1weekago date = CAST(DATEADD(week, -1, GETDATE()) AS date);

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
UPDATE OPEtiKo SET PackLiefDat = @curdate
FROM OPEtiKo
WHERE OPEtiKo.Status IN (N''J'', N''M'', N''P'')
  AND OPEtiKo.PackLiefDat < @date1weekago;
';

EXEC sp_executesql @sqltext, N'@curdate date, @date1weekago date', @curdate, @date1weekago;