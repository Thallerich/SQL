/***************************************************************************************************
** Wenn bei Artikel, die als OPTeile verwendet werden, mehr als eine Größe angelegt ist,          **
** so müssen diese den bestehenden OPTeilen manuell zugeordnet sein, um zu gewährleisten,         **
** dass die korrekte Artikelgröße verwendet wird.                                                 **
** Zum Zuordnen unten stehendes, auskommentiertes SQL verwenden!                                  **
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
    SELECT COUNT(OPTeile.ID)
    FROM OPTeile
    WHERE OPTeile.ArtikelID = Artikel.ID
      AND OPTeile.ArtGroeID <> -1
  ) AnzTeileMitGroe
FROM Artikel
WHERE Artikel.ID IN (
  SELECT DISTINCT OPTeile.ArtikelID
  FROM OPTeile 
  WHERE OPTeile.ArtGroeID = -1
)
  AND EXISTS (
    SELECT ArtGroe.ArtikelID, COUNT(ArtGroe.ID)
    FROM ArtGroe
    WHERE ArtGroe.ArtikelID = Artikel.ID
      AND ArtGroe.Groesse <> '-'
    GROUP BY ArtGroe.ArtikelID
    HAVING COUNT(ArtGroe.ID) > 1
  )
  AND NOT EXISTS (
    SELECT ArtGroe.*
    FROM ArtGroe
    WHERE ArtGroe.ArtikelID = Artikel.ID
      AND ArtGroe.Groesse =  '-'
  )
ORDER BY AnzGroe DESC;

-- Alternative zu oben - deutlich flotter:

WITH ArtMultiGroe AS (
  SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez, COUNT(ArtGroe.ID) AS AnzGroe
  FROM Artikel
  JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse <> N'-'
  GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.ArtikelBez
  HAVING COUNT(ArtGroe.ID) > 1
)
SELECT ArtMultiGroe.ArtikelID,
  ArtMultiGroe.ArtikelNr,
  ArtMultiGroe.ArtikelBez,
  [Teile ohne Größe] = (
    SELECT COUNT(OPTeile.ID)
    FROM OPTeile
    WHERE OPTeile.ArtikelID = ArtMultiGroe.ArtikelID
      AND OPTeile.ArtGroeID < 0
  ), 
  [Teile mit Größe] = (
    SELECT COUNT(OPTeile.ID)
    FROM OPTeile
    WHERE OPTeile.ArtikelID = ArtMultiGroe.ArtikelID
      AND OPTeile.ArtGroeID > 0
  )
FROM ArtMultiGroe
WHERE EXISTS (
  SELECT OPTeile.*
  FROM OPTeile
  WHERE OPTeile.ArtikelID = ArtMultiGroe.ArtikelID
    AND OPTeile.ArtGroeID < 0
);

-- Zum Zuordnen der korrekten Größe zu den Teilen - 0 durch tatsächliche IDs ersetzen:
/*
UPDATE OPTeile SET OPTeile.ArtGroeID = 0
WHERE OPTeile.ArtikelID = 0
  AND OPTeile.ArtGroeID = -1;
*/