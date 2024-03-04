CREATE OR ALTER VIEW [sapbw].[V_BW_ARTIKEL]
AS
  SELECT ArtikelNr = UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)),
    Artikel.ArtikelNr AS Artikelbasis,
    Artikel.ArtikelBez,
    Artikel.ArtikelBez AS ArtBezDE,
    Artikel.PackMenge AS VPE,
    IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode) AS Mengeneinheit,
    Artikel.StueckGewicht,
    Artikel.Status,
    Bereich.Bereich,
    N'-' AS Sortiergruppe,
    N'00' AS Sparte,
    ArtGru.Gruppe AS Artkelgruppe,
    Farbe.Farbe,
    IIF(ABC.ID < 0, NULL, ABC.ABC) AS ABC,
	  Artikel.EAN,
	  ArtGru.SetImSet,
	  MW =
      CASE Artikel._IstMwID
        WHEN 3 THEN N'E'
        WHEN 4 THEN N'M'
        ELSE N'S'
      END,
	  Artikel._Legezeit AS Legezeit,
	  Artikel._Tapelaenge AS TapeLaenge
  FROM Salesianer.dbo.Artikel
  LEFT JOIN Salesianer.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Salesianer.dbo.ME ON Artikel.MEID = ME.ID
  JOIN Salesianer.dbo.Bereich ON Artikel.BereichID = Bereich.ID
  JOIN Salesianer.dbo.ArtGru ON Artikel.ArtGruID = ArtGru.ID
  JOIN Salesianer.dbo.Farbe ON Artikel.FarbeID = Farbe.ID
  JOIN Salesianer.dbo.ABC ON Artikel.ABCID = ABC.ID
  WHERE Artikel.ID > 0
    AND ArtGru.Gruppe NOT IN (N'Fees', N'ContFW', N'MOD');
  
GO
