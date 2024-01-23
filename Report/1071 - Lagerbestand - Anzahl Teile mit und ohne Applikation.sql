WITH Lagerteile AS (
  SELECT EinzHist.ID AS EinzHistID, Lagerart.Lagerart, Lagerart.LagerartBez$LAN$ AS LagerartBez, EinzHist.ArtGroeID, CAST(IIF(EXISTS(SELECT TeilAppl.ID FROM TeilAppl WHERE TeilAppl.EinzHistID = EinzHist.ID), 1, 0) AS int) AS MitApplikation
  FROM EinzHist
  JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
  WHERE EinzHist.EinzHistTyp = 2 /* Lagerteile */
    AND EinzHist.[Status] = N'X' /* nur nicht reservierte Teile */
    AND EinzHist.LagerartID IN ($1$)
    AND Lagerart.SichtbarID IN ($SICHTBARIDS$)
    AND (($2$ > 0 AND EinzHist.ArtikelID = $2$) OR ($2$ < 0))
)
SELECT CONCAT(Lagerteile.LagerartBez, N' (', Lagerteile.Lagerart, N')') AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, SUM(IIF(Lagerteile.MitApplikation = 0, 1, 0)) AS [Anzahl Teile ohne Applikation], SUM(Lagerteile.MitApplikation) AS [Anzahl Teile mit Applikation]
FROM Lagerteile
JOIN ArtGroe ON Lagerteile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
GROUP BY CONCAT(Lagerteile.LagerartBez, N' (', Lagerteile.Lagerart, N')'), Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse