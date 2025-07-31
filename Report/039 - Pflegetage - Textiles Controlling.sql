/* Pipeline: Pflegedaten +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

[DROPTABLE, #PflegedatenArtGru];
[DROPTABLE, #PflegedatenProdHier];

IF ($2$ = 0)
BEGIN
  
  SELECT Abteil.Abteilung AS KoSt,
    Abteil.Bez AS Kostenstelle,
    ArtGru.ArtGruBez$LAN$ AS Artikelgruppe,
    PflegTag.Monat,
    SUM(LsPo.Menge) AS LiefermengeMonat,
    CAST(ROUND(SUM(LsPo.Menge * LsPo.EPreis * IIF(LsPo.RechPoID != -1, (100 - RechPo.RabattProz) / 100, (100 - KdBer.RabattWasch) / 100)), Wae.NK) AS money) AS UmsatzMonat,
    PflegTag.Pflegetage AS Pflegetage,
    CAST(ROUND(SUM(LsPo.Menge) / PflegTag.Pflegetage, 2) AS numeric(10,2)) AS LiefermengePflegetag,
    CAST(ROUND(SUM(LsPo.Menge * LsPo.EPreis * IIF(LsPo.RechPoID != -1, (100 - RechPo.RabattProz) / 100, (100 - KdBer.RabattWasch) / 100)) / PflegTag.Pflegetage, Wae.NK) AS money) AS UmsatzPflegetag,
    Wae.ID AS WaeID
  INTO #PflegedatenArtGru
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Abteil ON LsPo.AbteilID = Abteil.ID
  JOIN Kunden ON Abteil.KundenID = Kunden.ID
  JOIN Wae ON Kunden.VertragWaeID = Wae.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN PflegTag ON PflegTag.AbteilID = Abteil.ID AND PflegTag.Monat = CAST(DATEPART(year, LsKo.Datum) AS nchar(4)) + N'-' + RIGHT('0' + CAST(DATEPART(month, LsKo.Datum) AS nvarchar(2)), 2)
  WHERE Kunden.ID = $ID$
    AND LsKo.Datum >= $STARTDATE$
    AND LsKo.Datum <= $ENDDATE$
    AND PflegTag.Pflegetage != 0
  GROUP BY Abteil.Abteilung, Abteil.Bez, ArtGru.ArtGruBez$LAN$, PflegTag.Monat, PflegTag.Pflegetage, Wae.NK, Wae.ID;

END
ELSE
BEGIN
  
  SELECT Abteil.Abteilung AS KoSt,
    Abteil.Bez AS Kostenstelle,
    IIF(CHARINDEX(N' ', ProdHier.Hierarchie, 1) > 0, LEFT(ProdHier.Hierarchie, CHARINDEX(N' ', ProdHier.Hierarchie, 1)) + N' - ', N'') + ProdHier.ProdHierBez$LAN$ AS Produkthierarchie,
    PflegTag.Monat,
    SUM(LsPo.Menge) AS LiefermengeMonat,
    CAST(ROUND(SUM(LsPo.Menge * LsPo.EPreis * IIF(LsPo.RechPoID != -1, (100 - RechPo.RabattProz) / 100, (100 - KdBer.RabattWasch) / 100)), Wae.NK) AS money) AS UmsatzMonat,
    PflegTag.Pflegetage AS Pflegetage,
    CAST(ROUND(SUM(LsPo.Menge) / PflegTag.Pflegetage, 2) AS numeric(10,2)) AS LiefermengePflegetag,
    CAST(ROUND(SUM(LsPo.Menge * LsPo.EPreis * IIF(LsPo.RechPoID != -1, (100 - RechPo.RabattProz) / 100, (100 - KdBer.RabattWasch) / 100)) / PflegTag.Pflegetage, Wae.NK) AS money) AS UmsatzPflegetag,
    Wae.ID AS WaeID
  INTO #PflegedatenProdHier
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Abteil ON LsPo.AbteilID = Abteil.ID
  JOIN Kunden ON Abteil.KundenID = Kunden.ID
  JOIN Wae ON Kunden.VertragWaeID = Wae.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN PflegTag ON PflegTag.AbteilID = Abteil.ID AND PflegTag.Monat = CAST(DATEPART(year, LsKo.Datum) AS nchar(4)) + N'-' + RIGHT('0' + CAST(DATEPART(month, LsKo.Datum) AS nvarchar(2)), 2)
  WHERE Kunden.ID = $ID$
    AND LsKo.Datum >= $STARTDATE$
    AND LsKo.Datum <= $ENDDATE$
    AND PflegTag.Pflegetage != 0
  GROUP BY Abteil.Abteilung, Abteil.Bez, IIF(CHARINDEX(N' ', ProdHier.Hierarchie, 1) > 0, LEFT(ProdHier.Hierarchie, CHARINDEX(N' ', ProdHier.Hierarchie, 1)) + N' - ', N'') + ProdHier.ProdHierBez$LAN$, PflegTag.Monat, PflegTag.Pflegetage, Wae.NK, Wae.ID;

END;

/* Pipeline: Textiles Controlling ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @pivotcols1 nvarchar(max), @pivotcols2 nvarchar(max), @pivotcols3 nvarchar(max), @pivotcols4 nvarchar(max), @pivotcols5 nvarchar(max), @pivotcolshead nvarchar(max), @pivotsql nvarchar(max);

IF ($2$ = 0)
BEGIN

  IF (NOT EXISTS (SELECT 1 FROM #PflegedatenArtGru))
  BEGIN
    SET @pivotsql = N'SELECT N''Keine Daten vorhanden!'' AS Fehlermeldung;'
  END
  ELSE
  BEGIN

    SET @pivotcolshead = STUFF((SELECT DISTINCT N', SUM(ISNULL([' + Monat + N'], 0)) AS [Liefermenge ' + Monat + N'], SUM(ISNULL([' + Monat + N'_2], 0)) AS [Umsatz ' + Monat + N'], WaeID AS [Umsatz ' + Monat + N'_WaeID], SUM(ISNULL([' + Monat + N'_3], 0)) AS [Pflegetage ' + Monat + N'], SUM(ISNULL([' + Monat + N'_4], 0)) AS [Liefermenge je Pflegetag ' + Monat + N'], SUM(ISNULL([' + Monat + N'_5], 0)) AS [Umsatz je Pflegetag ' + Monat + N'], WaeID AS [Umsatz je Pflegetag ' + Monat + N'_WaeID]' FROM #PflegedatenArtGru ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');

    SET @pivotcols1 = STUFF((SELECT DISTINCT N', [' + Monat + N']' FROM #PflegedatenArtGru ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols2 = STUFF((SELECT DISTINCT N', [' + Monat + N'_2]' FROM #PflegedatenArtGru ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols3 = STUFF((SELECT DISTINCT N', [' + Monat + N'_3]' FROM #PflegedatenArtGru ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols4 = STUFF((SELECT DISTINCT N', [' + Monat + N'_4]' FROM #PflegedatenArtGru ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols5 = STUFF((SELECT DISTINCT N', [' + Monat + N'_5]' FROM #PflegedatenArtGru ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');

    SET @pivotsql = N'
      SELECT KoSt, Kostenstelle, Artikelgruppe,' + @pivotcolshead + N'
      FROM (
        SELECT #PflegedatenArtGru.*,
          #PflegedatenArtGru.Monat + N''_2'' AS Monat2,
          #PflegedatenArtGru.Monat + N''_3'' AS Monat3,
          #PflegedatenArtGru.Monat + N''_4'' AS Monat4,
          #PflegedatenArtGru.Monat + N''_5'' AS Monat5
        FROM #PflegedatenArtGru
      ) AS p
      PIVOT (
        SUM(LiefermengeMonat)
        FOR Monat IN (' + @pivotcols1 + N')
      ) AS pvt
      PIVOT (
        SUM(UmsatzMonat)
        FOR Monat2 IN (' + @pivotcols2 + N')
      ) AS pvt2
      PIVOT (
        SUM(Pflegetage)
        FOR Monat3 IN (' + @pivotcols3 + N')
      ) AS pvt3
      PIVOT (
        SUM(LiefermengePflegetag)
        FOR Monat4 IN (' + @pivotcols4 + N')
      ) AS pvt4
      PIVOT (
        SUM(UmsatzPflegetag)
        FOR Monat5 IN (' + @pivotcols5 + N')
      ) AS pvt5
      GROUP BY KoSt, Kostenstelle, Artikelgruppe, WaeID;
    ';

  END;

  EXEC sp_executesql @pivotsql;

END
ELSE
BEGIN

  IF (NOT EXISTS (SELECT 1 FROM #PflegedatenProdHier))
  BEGIN
    SET @pivotsql = N'SELECT N''Keine Daten vorhanden!'' AS Fehlermeldung;'
  END
  ELSE
  BEGIN

    SET @pivotcolshead = STUFF((SELECT DISTINCT N', SUM(ISNULL([' + Monat + N'], 0)) AS [Liefermenge ' + Monat + N'], SUM(ISNULL([' + Monat + N'_2], 0)) AS [Umsatz ' + Monat + N'], WaeID AS [Umsatz ' + Monat + N'_WaeID], SUM(ISNULL([' + Monat + N'_3], 0)) AS [Pflegetage ' + Monat + N'], SUM(ISNULL([' + Monat + N'_4], 0)) AS [Liefermenge je Pflegetag ' + Monat + N'], SUM(ISNULL([' + Monat + N'_5], 0)) AS [Umsatz je Pflegetag ' + Monat + N'], WaeID AS [Umsatz je Pflegetag ' + Monat + N'_WaeID]' FROM #PflegedatenProdHier ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');

    SET @pivotcols1 = STUFF((SELECT DISTINCT N', [' + Monat + N']' FROM #PflegedatenProdHier ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols2 = STUFF((SELECT DISTINCT N', [' + Monat + N'_2]' FROM #PflegedatenProdHier ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols3 = STUFF((SELECT DISTINCT N', [' + Monat + N'_3]' FROM #PflegedatenProdHier ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols4 = STUFF((SELECT DISTINCT N', [' + Monat + N'_4]' FROM #PflegedatenProdHier ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
    SET @pivotcols5 = STUFF((SELECT DISTINCT N', [' + Monat + N'_5]' FROM #PflegedatenProdHier ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');

    SET @pivotsql = N'
      SELECT KoSt, Kostenstelle, Produkthierarchie,' + @pivotcolshead + N'
      FROM (
        SELECT #PflegedatenProdHier.*,
          #PflegedatenProdHier.Monat + N''_2'' AS Monat2,
          #PflegedatenProdHier.Monat + N''_3'' AS Monat3,
          #PflegedatenProdHier.Monat + N''_4'' AS Monat4,
          #PflegedatenProdHier.Monat + N''_5'' AS Monat5
        FROM #PflegedatenProdHier
      ) AS p
      PIVOT (
        SUM(LiefermengeMonat)
        FOR Monat IN (' + @pivotcols1 + N')
      ) AS pvt
      PIVOT (
        SUM(UmsatzMonat)
        FOR Monat2 IN (' + @pivotcols2 + N')
      ) AS pvt2
      PIVOT (
        SUM(Pflegetage)
        FOR Monat3 IN (' + @pivotcols3 + N')
      ) AS pvt3
      PIVOT (
        SUM(LiefermengePflegetag)
        FOR Monat4 IN (' + @pivotcols4 + N')
      ) AS pvt4
      PIVOT (
        SUM(UmsatzPflegetag)
        FOR Monat5 IN (' + @pivotcols5 + N')
      ) AS pvt5
      GROUP BY KoSt, Kostenstelle, Produkthierarchie, WaeID;
    ';

  END;

  EXEC sp_executesql @pivotsql;

END