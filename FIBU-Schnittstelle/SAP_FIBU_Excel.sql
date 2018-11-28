DECLARE @OrderByAutoInc int;
DECLARE @KopfPos nchar(1);
DECLARE @Art nchar(2);
DECLARE @Belegdat date;
DECLARE @WaeCode nchar(4);
DECLARE @BelegNr int;
DECLARE @Nettowert money;
DECLARE @Bruttowert money;
DECLARE @Steuerschl nchar(2);
DECLARE @Debitor nchar(24);
DECLARE @Gegenkonto nchar(17);
DECLARE @Kostenstelle nchar(10);
DECLARE @ZahlZiel nchar(4);
DECLARE @BasisRechnung nchar(10);
DECLARE @KdGfFibuNr nchar(4);
DECLARE @Buchungskreis int;

DECLARE @i int = 0;

DECLARE @output TABLE (
  [Order] int,
  Typ nchar(6),
  bldat nchar(8),
  blart nchar(2),
  bukrs nchar(4),
  budat nchar(8),
  waers nchar(5),
  belnr nchar(10),
  xblnr nchar(14),
  newbs nchar(2),
  wrbtr nchar(16),
  mwskz nchar(2),
  zfbdt nchar(8),
  zterm nchar(4),
  rebzg nchar(10),
  newko nchar(17),
  kostl nchar(10),
  zuor nchar(18)
);

DECLARE fibuexp CURSOR LOCAL FAST_FORWARD FOR
  SELECT Export.OrderByAutoInc, Export.KopfPos,
    Belegart =
      CASE
        WHEN Firma.SuchCode = N'SAL' AND Export.Art = N'R' THEN N'AU'
        WHEN Firma.SuchCode = N'SMBU' AND Export.Art = N'R' THEN N'VF'
        WHEN Firma.SuchCode = N'WOMI' AND Export.Art = N'R' THEN N'AR'
        WHEN Firma.SuchCode = N'UKLU' AND Export.Art = N'R' THEN N'AR'
        WHEN Firma.SuchCode = N'SAL' AND Export.Art = N'G' THEN N'GA'
        WHEN Firma.SuchCode = N'SMBU' AND Export.Art = N'G' THEN N'VS'
        WHEN Firma.SuchCode = N'WOMI' AND Export.Art = N'G' THEN N'GU'
        WHEN Firma.SuchCode = N'UKLU' AND Export.Art = N'G' THEN N'GU'
        ELSE N'XX'
      END,
    Export.Belegdat, Wae.IsoCode AS WaeCode, Export.BelegNr, Export.Nettowert, IIF(Wae.IsoCode = N'CZK', Export.Bruttowert, Export.Bruttowert) AS Bruttowert,
    Steuerschl =
      CASE
        WHEN MwSt.SteuerSchl = N'6Z' AND Export.Art = N'G' THEN N'6O'
        WHEN MwSt.Steuerschl = N'A6' THEN N'33'
        ELSE MwSt.Steuerschl
      END,
    Export.Debitor, Export.Gegenkonto, 
    Kostenstelle =
      CASE
        WHEN Export.Gegenkonto = N'480004' AND KdGf.KurzBez = N'JOB' THEN N'1400'
        WHEN Export.Gegenkonto = N'480004' AND KdGf.KurzBez = N'MED' THEN N'2400'
        WHEN Export.Gegenkonto = N'480004' AND KdGf.KurzBez = N'GAST' THEN N'1310'
        ELSE Export.Kostenstelle
      END,
    Export.ZahlZiel, IIF(RechKo.BasisRechKoID > 0 AND RechKo.Art = N'G', CAST(BasisRechKo.RechNr AS nchar(10)), NULL) AS BasisRechnung,
    KdGfFibuNr = 
      CASE
        WHEN Firma.SuchCode = N'UKLU' THEN CAST(93 AS nchar(3))
        WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode = N'UKLU' THEN CAST(90 AS nchar(3))  --Salesianer SÜD
        WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode <> N'UKLU' THEN CAST(40 AS nchar(3))  --Salesianer WEST
        WHEN Firma.SuchCode = N'SMBU' THEN CAST(895 AS nchar(3))
        ELSE CAST(KdGf.FibuNr AS nchar(3))
      END,
    Buchungskreis = 
      CASE Firma.SuchCode 
        WHEN N'UKLU' THEN 1260
        WHEN N'SAL' THEN 1200
        WHEN N'WOMI' THEN 1250
        WHEN N'SMBU' THEN 1900
        ELSE 1250
      END
  FROM #bookingexport AS Export
  JOIN RechKo ON Export.RechKoID = RechKo.ID
  JOIN RechKo AS BasisRechKo ON RechKo.BasisRechKoID = BasisRechKo.ID
  JOIN Wae ON RechKo.WaeID = Wae.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN Firma ON RechKo.FirmaID = Firma.ID
  JOIN MwSt ON RechKo.MwStID = MwSt.ID
  WHERE Export.KopfPos IN (N'K', N'P')
  ORDER BY OrderByAutoInc ASC;

OPEN fibuexp;

FETCH NEXT FROM fibuexp INTO @OrderByAutoInc, @KopfPos, @Art, @Belegdat, @WaeCode, @BelegNr, @Nettowert, @Bruttowert, @Steuerschl, @Debitor, @Gegenkonto, @Kostenstelle, @ZahlZiel, @BasisRechnung, @KdGfFibuNr, @Buchungskreis;
SET @i =  @i + 1;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @KopfPos = N'K'
  BEGIN
    
    --BBKPF - Belegkopf für Buchhaltungsbeleg
    INSERT INTO @output ([Order], Typ, bldat, blart, bukrs, budat, waers, belnr, xblnr)
    SELECT @i AS [Order],
      N'1FB01' AS Typ,
      FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') AS bldat,
      @Art AS blart,
      CAST(@Buchungskreis AS nchar(4)) AS bukrs,
      FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') AS budat,
      CAST(ISNULL(@WaeCode, N'') AS nchar(5)) AS waers,
      CAST(@BelegNr AS nchar(10)) AS belnr,
      @Art + CAST(@BelegNr AS nchar(14)) AS xblnr;

    SET @i = @i + 1;

    -- BBSEG-KD - Belegkopf für Buchhaltungsbeleg - Kundenbuchung
    INSERT INTO @output ([Order], Typ, newbs, wrbtr, mwskz, zfbdt, zterm, rebzg, newko)
    SELECT @i AS [Order], 
      N'2ZBSEG' AS Typ,
      IIF(@Bruttowert < 0, N'11', N'01') AS newbs,
      CAST(FORMAT(ABS(IIF(@WaeCode = N'CZK', ROUND(@Bruttowert, 0), @Bruttowert)), 'F2', 'de-AT') AS nchar(16)) AS wrbtr,
      CAST(ISNULL(@Steuerschl, N'') AS nchar(2)) AS mwskz,
      FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') AS zfbdt,
      CAST(ISNULL(@ZahlZiel, N'') AS nchar(4)) AS zterm,
      ISNULL(@BasisRechnung, CAST(N'' AS nchar(10))) AS rebzg,
      LEFT(ISNULL(@Debitor, CAST(N'' AS nchar(24))), 17) AS newko;

    SET @i = @i + 1;
  END;

  IF @KopfPos = N'P'
  BEGIN
    -- BBESG-ERLKTO - Belegkopf für Buchhaltungsbeleg - Erlöskontobuchung
    INSERT INTO @output ([Order], Typ, newbs, wrbtr, kostl, zuor, newko)
    SELECT @i AS [Order], 
      N'2ZBSEG' AS Typ,
        IIF(@Bruttowert < 0, N'40', N'50') AS newbs,
        CAST(FORMAT(ABS(@Bruttowert), 'F2', 'de-AT') AS nchar(16)) AS wrbtr,
        CAST(RTRIM(ISNULL(@KdGfFibuNr, N'')) + ISNULL(@Kostenstelle, N'') AS nchar(10)) AS kostl,
        LEFT(ISNULL(@Debitor, CAST(N'' AS nchar(24))), 18) AS zuor,
        CAST(ISNULL(@Gegenkonto, N'') AS nchar(17)) AS newko;

    SET @i = @i + 1;
  END;

  FETCH NEXT FROM fibuexp INTO @OrderByAutoInc, @KopfPos, @Art, @Belegdat, @WaeCode, @BelegNr, @Nettowert, @Bruttowert, @Steuerschl, @Debitor, @Gegenkonto, @Kostenstelle, @ZahlZiel, @BasisRechnung, @KdGfFibuNr, @Buchungskreis;
END;

CLOSE fibuexp;
DEALLOCATE fibuexp;

SELECT * FROM @output ORDER BY [Order] ASC;
