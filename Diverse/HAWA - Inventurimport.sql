WITH LagerbewNachInv AS (
  SELECT LagerBew.BestandID, LagerBew.LagerOrtID, SUM(LagerBew.Differenz) AS BuchMenge
  FROM LagerBew
  WHERE LagerBew.Zeitpunkt > N'2022-03-31 23:59:59'
    AND LagerBew.BenutzerID != (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
  GROUP BY LagerBew.BestandID, LagerBew.LagerOrtID
)
SELECT BestOrt.ID AS BestOrtID, Bestand.ID AS BestandID, Bestand.Bestand, ME.MeBez, Bestand.InBestReserv, Bestand.InBestUnreserv, Bestand.Reserviert, Lagerort.Lagerort, Artikel.ArtikelNr, Artikel.SuchCode, Artikel.ArtikelBez, Lagerart.Lagerart, Lagerart.LagerartBez, ArtGroe.Groesse, ArtGroe.Ehemals, IIF(CAST(_HAWAInv.Inventurmenge AS int) + ISNULL(LagerbewNachInv.BuchMenge, 0) < 0, 0, CAST(_HAWAInv.Inventurmenge AS int) + ISNULL(LagerbewNachInv.BuchMenge, 0)) AS Inventurmenge
FROM BestOrt
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Lagerort ON BestOrt.LagerOrtID = Lagerort.ID
JOIN Me ON Artikel.MeID = Me.ID
JOIN _HAWAInv ON _HAWAInv.ArtikelNr COLLATE Latin1_General_CS_AS = Artikel.ArtikelNr AND _HAWAInv.Groesse COLLATE Latin1_General_CS_AS = ArtGroe.Groesse AND _HAWAInv.Lagerart COLLATE Latin1_General_CS_AS = Lagerart.Lagerart
LEFT JOIN LagerbewNachInv ON LagerbewNachInv.LagerOrtID = Lagerort.ID AND LagerbewNachInv.BestandID = Bestand.ID
--WHERE Artikel.ArtikelNr = N'A591TW'
ORDER BY Inventurmenge ASC;