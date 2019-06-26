SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, TextArt.TextArtBez AS Textart, VsaTexte.VonDatum, VsaTexte.BisDatum, VsaTexte.Memo AS [Text], Mitarbei.Name AS [angelegt von], CAST(VsaTexte.Anlage_ AS date) AS [angelegt am]
FROM VsaTexte
JOIN TextArt ON VsaTexte.TextArtID = TextArt.ID
JOIN Kunden ON VsaTexte.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Mitarbei ON VsaTexte.AnlageUserID_ = Mitarbei.ID
WHERE TextArt.Fahrtenbuch = 1
  AND VsaTexte.VsaID = -1
  AND VsaTexte.BisDatum > CAST(GETDATE() AS date)