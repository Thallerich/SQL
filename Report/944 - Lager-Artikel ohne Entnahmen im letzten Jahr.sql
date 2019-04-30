WITH Lagerbestand AS (
  SELECT BestandRaw.ArtGroeID, BestandRaw.LagerID, MAX(IIF(BestandRaw.Neuwertig = 1, BestandRaw.Lagerbestand, 0)) AS BestandNeuware, MAX(IIF(BestandRaw.Neuwertig = 0, BestandRaw.Lagerbestand, 0)) AS BestandGebrauchtware, MAX(BestandRaw.LetzteLagerbewegung) AS LetzteLagerbewegung
  FROM (
    SELECT Bestand.ArtGroeID, LagerArt.LagerID, LagerArt.Neuwertig, SUM(Bestand.Bestand) AS Lagerbestand, MAX(LagerBew.Zeitpunkt) AS LetzteLagerbewegung
    FROM Bestand
    JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
    LEFT OUTER JOIN LagerBew ON LagerBew.BestandID = Bestand.ID
    WHERE LagerArt.LagerID IN ($1$)
      AND Bestand.Bestand <> 0
    GROUP BY Bestand.ArtGroeID, LagerArt.LagerID, LagerArt.Neuwertig
  ) AS BestandRaw
  GROUP BY BestandRaw.ArtGroeID, BestandRaw.LagerID
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Standort.Bez AS Lagerstandort, ArtGroe.EntnahmeJahr AS [Jahressumme Entnahmen], Lagerbestand.BestandNeuware AS [Bestand Neuware], Lagerbestand.BestandGebrauchtware AS [Bestand Gebraucht], CAST(Lagerbestand.LetzteLagerbewegung AS date) AS [Letzte Lagerbewegung]
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerbestand ON Lagerbestand.ArtGroeID = ArtGroe.ID
JOIN Standort ON Lagerbestand.LagerID = Standort.ID
WHERE ArtGroe.EntnahmeJahr = 0;