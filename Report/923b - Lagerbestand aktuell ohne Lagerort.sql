SELECT Standort.Bez AS Lagerstandort,
  Lagerart.LagerartBez$LAN$ AS Lagerart,
  LagerArt.Neuwertig,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  Artikelstatus.StatusBez AS Artikelstatus,
  ArtGroe.Groesse,
  Bestand.Bestand,
  Bestand.Reserviert,
  Bestand.BestandUrsprung AS [Bestand vom Ursprungsartikel],
  Bestand.Umlauf,
  ISNULL(Bestellt.Bestellt, 0) AS Bestellt,
  Entnahmen.AnzEntnahmen AS [Entnahmen 12 Monate],
  Bestand.GleitPreis AS GLD
FROM Bestand
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
) AS Artikelstatus ON Artikel.Status = Artikelstatus.Status
LEFT JOIN (
  SELECT BKo.LagerArtID, BPo.ArtGroeID, SUM(BPo.Menge - BPo.LiefMenge) AS Bestellt
  FROM BPo
  JOIN BKo ON BPo.BKoID = BKo.ID
  WHERE BKo.[Status] < N'M'
  GROUP BY BKo.LagerArtID, BPo.ArtGroeID
  HAVING SUM(BPo.Menge - BPo.LiefMenge) > 0
) AS Bestellt ON Bestand.LagerArtID = Bestellt.LagerArtID AND Bestand.ArtGroeID = Bestellt.ArtGroeID
LEFT JOIN (
  SELECT LagerBew.BestandID, ABS(SUM(LagerBew.Differenz)) AS AnzEntnahmen
  FROM LagerBew
  WHERE LagerBew.Zeitpunkt >= DATEADD(year, -1, CAST(GETDATE() AS date))
    AND LagerBew.LgBewCodID IN (SELECT LgBewCod.ID FROM LgBewCod WHERE (LgBewCod.IstEntnahme = 1 OR LgBewCod.Code = N'UMZL'))
  GROUP BY LagerBew.BestandID
) AS Entnahmen ON Bestand.ID = Entnahmen.BestandID
WHERE Standort.ID IN ($1$)
  AND Artikel.BereichID IN ($2$)
  AND Bestand.Bestand != 0
  AND Lagerart.ArtiTypeID = 1
  AND (($3$ = 1 AND Lagerart.Neuwertig = 1) OR ($3$ = 0));