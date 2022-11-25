SELECT Traeger, Nachname, Vorname, ArtikelNr, ArtikelBez, Groesse, COUNT(EinzHistID) AS [Anzahl Teile], Aktion, Zeitpunkt, COUNT(Retourniert) AS [Anzahl retourniert]
FROM (
  SELECT Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, EinzHist.ID AS EinzHistID, Actions.ActionsBez AS Aktion, FORMAT(Scans.[DateTime], N'dd.MM.yyyy HH:mm') AS Zeitpunkt, Retourniert = (
    SELECT DISTINCT s.EinzHistID
    FROM Scans s
    WHERE s.EinzHistID = EinzHist.ID
      AND s.[DateTime] >= Scans.[DateTime]
      AND s.ActionsID = 66
  )
  FROM Scans
  JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
  JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Actions ON Scans.ActionsID = Actions.ID
  JOIN Traeger ON Scans.LastPoolTraegerID = Traeger.ID
  WHERE EinzHist.VsaID = 6140348
    AND Scans.[DateTime] > CAST(GETDATE() AS date)
    AND Scans.ActionsID = 65
) SmartroomDaten
GROUP BY Traeger, Nachname, Vorname, ArtikelNr, ArtikelBez, Groesse, Aktion, Zeitpunkt
ORDER BY Zeitpunkt ASC;

GO