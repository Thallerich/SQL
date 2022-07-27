WITH Memotext AS (
  SELECT VsaTexte.KundenID, VsaTexte.VonDatum, VsaTexte.BisDatum, TextArt.TextArtBez, VsaTexte.Memo
  FROM VsaTexte
  JOIN TextArt ON VsaTexte.TextArtID = TextArt.ID
    AND CAST(N'2022-08-01' AS date) BETWEEN VsaTexte.VonDatum AND VsaTexte.BisDatum
    AND TextArt.TextArtBez = N'Fakturatext Fuß'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Memotext.TextArtBez AS Textart, Memotext.VonDatum AS [gültig ab], Memotext.BisDatum AS [gültig bis], Memotext.Memo AS [Text]
FROM PePo
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
LEFT JOIN Memotext ON Memotext.KundenID = Kunden.ID
WHERE PePo.PeKoID = 741
  AND PePo.PeProzent != 0
  AND EXISTS (
    SELECT PrArchiv.*
    FROM PrArchiv
    JOIN KdArti ON PrArchiv.KdArtiID = KdArti.ID
    WHERE PrArchiv.PeKoID = PePo.PeKoID
      AND KdArti.KundenID = Kunden.ID
  )
  AND Kunden.AdrArtID = 1;