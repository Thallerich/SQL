SELECT HinwText.HinwtextBez AS Bezeichnung, HinwText.Bez AS Code, COUNT(Hinweis.ID) AS [Anzahl Hinweise]
FROM HinwText
JOIN Hinweis ON Hinweis.HinwTextID = HinwText.ID
JOIN Teile ON Hinweis.TeileID = Teile.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Hinweis.Aktiv = 1
  AND Hinweis.BestaetDatum IS NULL
  AND Teile.Status BETWEEN N'K' AND N'W'
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Hinwtext.ID > 0
GROUP BY HinwText.HinwtextBez, HinwText.Bez;