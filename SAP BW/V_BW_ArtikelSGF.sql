CREATE OR ALTER VIEW [sapbw].[V_BW_ArtikelSGF] AS
   SELECT UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS Artikel,
    KdGf.KurzBez,
    COUNT(DISTINCT IIF(Kunden.Status = N'A' AND KdArti.Status = N'A', Kunden.ID, NULL)) AS AnzKunden,
    COUNT(DISTINCT IIF(Kunden.Status = N'A' AND KdArti.Status = N'A' AND KdArti.Vertragsartikel = 1, Kunden.ID, NULL)) AS AnzVertragskunden,
    SUM(_Umlauf.Umlauf) AS Umlauf
  FROM Salesianer.dbo._Umlauf
  JOIN Salesianer.dbo.KdArti ON _Umlauf.KdArtiID = KdArti.ID
	JOIN Salesianer.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
	JOIN Salesianer.dbo.Kunden ON KdArti.KundenID = Kunden.ID
	JOIN Salesianer.dbo.KdGf ON Kunden.KdGfID = KdGf.ID
	JOIN Salesianer.dbo.ArtGroe ON _Umlauf.ArtGroeID = ArtGroe.ID
	WHERE _Umlauf.Datum >= DATEADD(day, -7, CAST(GETDATE() AS date))
		AND Artikel.ID > 0
	GROUP BY UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)), KdGf.KurzBez;

GO