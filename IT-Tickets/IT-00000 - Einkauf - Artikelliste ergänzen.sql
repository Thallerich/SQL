/* WITH ArtikelLieferant AS (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, ArtikelLief.LiefNr, ArtikelLief.SuchCode, Artikel.ArtikelNr + IIF(ArtGroe.ID IS NOT NULL, '-' + ArtGroe.Groesse, '') AS Material
  FROM Salesianer_Test.dbo.Artikel
  LEFT JOIN Salesianer_Test.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Salesianer_Test.dbo.Lief AS ArtikelLief ON Artikel.LiefID = ArtikelLief.ID
)
SELECT EKList.*, ArtikelLieferant.LiefNr, ArtikelLieferant.SuchCode
FROM Salesianer_Test.dbo.__EKxlsx AS EKList
LEFT JOIN ArtikelLieferant ON ArtikelLieferant.Material = EKList.Material COLLATE Latin1_General_CS_AS;

GO */

SELECT EKList.*, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.ArtikelNr2, Artikel.Memo
FROM Salesianer_Test.dbo.__EKxlsx AS EKList
LEFT JOIN Salesianer_Test.dbo.Artikel ON Artikel.ArtikelNr = IIF(CHARINDEX(N'-', EKList.Material, 1) = 0, EKList.Material, LEFT(EKList.Material, CHARINDEX(N'-', EKList.Material, 1) - 1)) COLLATE Latin1_General_CS_AS;

GO