CREATE OR ALTER VIEW [sapbw].[V_BW_STANDORT] AS
  SELECT SuchCode = IIF(Standort.SuchCode = N'SALESIANER MIET', SUBSTRING(Standort.Bez, CHARINDEX(N' ', Standort.Bez, 1) + 1, CHARINDEX(N':', Standort.Bez, 1) - CHARINDEX(N' ', Standort.Bez, 1) - 1), iif(Standort.Bez LIKE N'%ehem. Asten%','SMA', Standort.SuchCode)),
    Name1 = Standort.Bez,
    Region = IIF(Standort.SuchCode = N'SZAT', N'AT', Standort.Land) + ISNULL(N' - ' + Standort.Statistik3, N''),
    Standort.Ort,
    Standort.FibuNr,
    Produktionsabteilung =
      CASE Standort.FibuNr
        WHEN 92 THEN N'KLAGENFURT'
        WHEN 641 THEN N'FLACHWÄSCHE'
        WHEN 642 THEN N'FLACHWÄSCHE SH'
        WHEN 643 THEN N'BEKLEIDUNG'
        WHEN 645 THEN N'STERILDIENST'
        WHEN 654 THEN N'PWS'
        WHEN 661 THEN N'FLACHWÄSCHE'
        WHEN 663 THEN N'BEKLEIDUNG'
        WHEN 666 THEN N'MICRONCLEAN'
        WHEN 681 THEN N'BAD HOFGASTEIN'
        ELSE N''
      END
  FROM Salesianer.dbo.Standort
  WHERE Standort.ID > 0 
    AND Standort.ID <> 5331;