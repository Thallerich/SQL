DECLARE @RechNr int = 1210000001;
DECLARE @CorrDate date = N'2023-03-31';
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
UPDATE RechKo SET RechDat = @rechdat, 
  FaelligDat = DATEADD(day, ZahlZiel.NettoTage, @rechdat),
  SteuerDat = DATEADD(day, ZahlZiel.NettoTage, @rechdat),
  MwStDat = @rechdat
FROM RechKo
JOIN ZahlZiel ON RechKo.ZahlZielID = ZahlZiel.ID
WHERE RechKo.RechNr = @rechnr;
';

EXEC sp_executesql @sqltext, N'@rechnr int, @rechdat date', @RechNr, @CorrDate;

GO