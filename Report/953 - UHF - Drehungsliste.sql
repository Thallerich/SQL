DECLARE @sqltext nvarchar(max);
DECLARE @stark int, @schwach int, @kaum int, @kundenid int;

SET @kundenid = $1$;
SET @stark = $2$;
SET @schwach = $3$;
SET @kaum = $4$;

IF @schwach < @stark
  RAISERROR(N'Schwach drehend muss größer Stark drehend sein!', 15, 1);

IF @kaum < @schwach
  RAISERROR(N'Kaum drehend muss größer als Schwach drehend sein!', 15, 2);

SET @sqltext = N'
  SELECT KdGf.KurzBez AS SGF,
    Bereich.BereichBez$LAN$ AS Produktbereich,
    Kunden.KdNr,
    Kunden.SuchCode AS  [Kunde SuchCode],
    Vsa.ID AS VsaID,
    Vsa.Bez AS Vsa,
    Artikel.ArtikelNr,
    Artikel.ArtikelBez$LAN$ AS Artikel,
    ISNULL(VsaAnf.Bestand, 0) AS Vertragsbestand,
    SUM(IIF(OPTeile.Status = N''Q'', 1, 0)) AS [Teile beim Kunden],
    SUM(IIF(OPTeile.Status = N''W'' AND OPTeile.RechPoID > 0, 1, 0)) AS [Schwundmarkiert (verrechnet)],
    SUM(IIF(OPTeile.Status = N''W'' AND OPTeile.RechPoID < 0, 1, 0)) AS [Schwundmarkiert (nicht verrechnet)],
    SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= @stark AND OPTeile.Status = N''Q'', 1, 0)) AS [stark drehend <= ' + CAST(@stark AS nvarchar) + '],
    SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > @stark AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= @schwach AND OPTeile.Status = N''Q'', 1, 0)) AS [schwach drehend <= ' + CAST(@schwach AS nvarchar) + '],
    SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > @schwach AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= @kaum AND OPTeile.Status = N''Q'', 1, 0)) AS [kaum drehend <= ' + CAST(@kaum AS nvarchar) +'],
    SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > @kaum AND OPTeile.Status = N''Q'', 1, 0)) AS [nicht drehend > ' + CAST(@kaum AS nvarchar) + ']
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID
  LEFT JOIN VsaAnf ON VsaAnf.VsaID = Vsa.ID AND VsaAnf.KdArtiID = KdArti.ID
  WHERE Kunden.ID = @kundenid
    AND OPTeile.Status IN (N''Q'', N''W'')
    AND OPTeile.LastActionsID IN (102, 116, 120, 136)
  GROUP BY KdGf.KurzBez, Bereich.BereichBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, VsaAnf.Bestand;
';

EXEC sp_executesql @sqltext, N'@kundenid int, @stark int, @schwach int, @kaum int', @kundenid, @stark, @schwach, @kaum;