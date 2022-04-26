DECLARE @Barcode nvarchar(33) = $1$;
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'SELECT TOP 1 LagerBew.Barcode, EntnPo.EntnKoID AS Entnahmeliste, LagerBew.Zeitpunkt ' + CHAR(13) + CHAR(10) +
N'FROM LagerBew ' + CHAR(13) + CHAR(10) +
N'JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID' + CHAR(13) + CHAR(10) + 
N'JOIN EntnPo ON LagerBew.EntnPoID = EntnPo.ID' + CHAR(13) + CHAR(10) + 
N'WHERE LagerBew.Barcode = @Barcode ' + CHAR(13) + CHAR(10) + 
N'ORDER BY LagerBew.ID;';

EXEC sp_executesql @sqltext, N'@Barcode nvarchar(33)', @Barcode;