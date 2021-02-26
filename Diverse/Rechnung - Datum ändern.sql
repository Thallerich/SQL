DECLARE @RechNr int = 30082660;
DECLARE @CorrDate date = N'2021-02-21';

UPDATE RechKo SET RechDat = @CorrDate, 
  FaelligDat = DATEADD(day, ZahlZiel.NettoTage, @CorrDate),
  SteuerDat = DATEADD(day, ZahlZiel.NettoTage, @CorrDate),
  MwStDat = @CorrDate
FROM RechKo
JOIN ZahlZiel ON RechKo.ZahlZielID = ZahlZiel.ID
WHERE RechKo.RechNr = @RechNr;

GO