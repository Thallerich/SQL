CREATE OR ALTER VIEW [sapbw].[V_BW_ARTGRU] AS
SELECT DISTINCT ArtGru.Gruppe, ArtGru.Steril
FROM Salesianer.dbo.ArtGru
WHERE EXISTS (
    SELECT Artikel.*
    FROM Salesianer.dbo.Artikel
    WHERE Artikel.ArtGruID = ArtGru.ID
  )
  AND ArtGru.Gruppe NOT IN ('ContFW', 'EA', 'Fees');