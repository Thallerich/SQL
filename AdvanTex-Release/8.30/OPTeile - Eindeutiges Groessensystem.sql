/***************************************************************************************************
** Es dürfen entweder nur die Größe '-' oder nur "echte" Größen bei einem Artikel existieren!     **
** Skript listet alle Artikel auf, die als OPTeile verwendet werden, und wo                       **
** sowohl die Größe '-' als auch andere Größen angelegt sind                                      **
***************************************************************************************************/

SELECT Artikel.ID AS ArtikelID,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  (
    SELECT COUNT(ArtGroe.ID)
    FROM ArtGroe
    WHERE ArtGroe.ArtikelID = Artikel.ID
  ) AnzGroe,
  (
    SELECT COUNT(OPTeile.ID)
    FROM OPTeile
    WHERE OPTeile.ArtikelID = Artikel.ID
      AND OPTeile.ArtGroeID = -1
  ) AnzTeileOhneGroe,
  (
    SELECT COUNT(*)
    FROM OPTeile
    WHERE OPTeile.ArtikelID = Artikel.ID
      AND OPTeile.ArtGroeID <> -1
  ) AnzTeileMitGroe
FROM Artikel
WHERE Artikel.ID IN (
  SELECT DISTINCT OPTeile.ArtikelID 
  FROM OPTeile
)
  AND EXISTS (
    SELECT ArtGroe.*
    FROM ArtGroe
    WHERE ArtGroe.ArtikelID = Artikel.ID
      AND ArtGroe.Groesse <> '-'
  )
  AND EXISTS (
    SELECT ArtGroe.*
    FROM ArtGroe
    WHERE ArtGroe.ArtikelID = Artikel.ID
    AND ArtGroe.Groesse =  '-'
  )
ORDER BY AnzGroe DESC;