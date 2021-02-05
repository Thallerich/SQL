WITH Entnahmen AS (
  SELECT LagerBew.BestandID, COUNT(LagerBew.ID) AS AnzEntnahmen
  FROM LagerBew
  WHERE DATEDIFF(year, LagerBew.Zeitpunkt, GETDATE()) <= 12
    AND LagerBew.LgBewCodID IN (SELECT LgBewCod.ID FROM LgBewCod WHERE LgBewCod.IstEntnahme = 1)
  GROUP BY LagerBew.BestandID
)
SELECT Bereich.BereichBez AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Standort.Bez AS Lagerstandort, LagerArt.Neuwertig AS IstNeuware, SUM(Bestand.Bestand) AS Lagerbestand, ISNULL(SUM(Entnahmen.AnzEntnahmen), 0) AS [Entnahmen letzte 12 Monate], CAST(ROUND(CAST(ISNULL(SUM(Entnahmen.AnzEntnahmen), 0) AS float) / 12, 0) AS int) AS [Durschnittliche monatliche Entnahmen], SUM(Bestand.Umlauf) AS Umlaufmenge
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
LEFT OUTER JOIN Entnahmen ON Entnahmen.BestandID = Bestand.ID
WHERE Standort.ID IN ($1$)
  AND (Bestand.Bestand <> 0 OR ArtGroe.EntnahmeJahr <> 0)
  AND LagerArt.IstAnfLager = 0
GROUP BY Bereich.BereichBez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Standort.Bez, LagerArt.Neuwertig;