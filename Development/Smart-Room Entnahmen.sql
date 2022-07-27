SELECT Traeger, Nachname, Vorname, ArtikelNr, ArtikelBez, Groesse, COUNT(TeileID) AS [Anzahl Teile], Aktion, Zeitpunkt, COUNT(Retourniert) AS [Anzahl retourniert]
FROM (
  SELECT Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Teile.ID AS TeileID, Actions.ActionsBez AS Aktion, FORMAT(Scans.[DateTime], N'dd.MM.yyyy HH:mm') AS Zeitpunkt, Retourniert = (
    SELECT DISTINCT s.TeileID
    FROM Scans s
    WHERE s.TeileID = Teile.ID
      AND s.[DateTime] >= Scans.[DateTime]
      AND s.ActionsID = 66
  )
  FROM Scans
  JOIN Teile ON Scans.TeileID = Teile.ID
  JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Actions ON Scans.ActionsID = Actions.ID
  JOIN Traeger ON Scans.LastPoolTraegerID = Traeger.ID
  WHERE Teile.VsaID = 6140348
    AND Scans.[DateTime] > CAST(GETDATE() AS date)
    AND Scans.LastPoolTraegerID > 0
) SmartroomDaten
GROUP BY Traeger, Nachname, Vorname, ArtikelNr, ArtikelBez, Groesse, Aktion, Zeitpunkt
ORDER BY Zeitpunkt ASC;

GO