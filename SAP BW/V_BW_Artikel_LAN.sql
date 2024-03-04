CREATE OR ALTER VIEW [sapbw].[V_BW_ARTIKEL_LAN] AS
  SELECT ArtikelNr AS Artikel, Spras, Bez
  FROM (
    SELECT ArtikelNr = UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)), Artikel.ArtikelBez AS N'D', Artikel.ArtikelBez1 AS N'E', Artikel.ArtikelBez2 AS N'C', Artikel.ArtikelBez3 AS N'4', Artikel.ArtikelBez4 AS N'Q', Artikel.ArtikelBez5 AS N'H', Artikel.ArtikelBez6 AS N'I', Artikel.ArtikelBez7 AS N'6', Artikel.ArtikelBez8 AS N'5'
    FROM Salesianer.dbo.Artikel
	  LEFT JOIN Salesianer.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
	  WHERE Artikel.ID > 0
	    AND Artikel.ArtGruID <> 26563
  ) AS ArtiData
  UNPIVOT (Bez FOR Spras IN ([D], [E], [C], [4], [Q], [H], [I], [6], [5])) AS unpvt;
GO