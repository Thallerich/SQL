DECLARE @pznr nchar(8) = N'23691461';
DECLARE @sqltext nvarchar(max)

SET @sqltext = N'
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, COUNT(Scans.ID) AS AnzGelesen
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Scans.AnfPoID IN (
  SELECT AnfPo.ID
  FROM AnfPo, AnfKo
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfKo.AuftragsNr = @PzNr
)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse
ORDER BY ArtikelNr, Groesse;
';

EXEC sp_executesql @sqltext, N'@pznr nchar(8)', @pznr;

SET @sqltext = N'
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, AnfPo.Angefordert, AnfPo.Geliefert, AnfPo.BestaetZeitpunkt
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
WHERE (AnfPo.Angefordert != 0 OR AnfPo.Geliefert != 0)
  AND AnfKo.AuftragsNr = @pznr
ORDER BY ArtikelNr, Groesse;
';

EXEC sp_executesql @sqltext, N'@pznr nchar(8)', @pznr;