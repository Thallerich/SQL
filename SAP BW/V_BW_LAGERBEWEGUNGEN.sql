CREATE OR ALTER VIEW [sapbw].[V_BW_LAGERBEWEGUNGEN] AS
SELECT N'ADV' AS [System],
  LagerBew.ID AS BewID,
  LagerBew.BestandID,
  LagerBew.BestandNeu,
  CAST(LagerBew.Zeitpunkt AS date) AS Datum,
  Standort.Bez,
  Standort = IIF(Standort.SuchCode = N'SALESIANER MIET', SUBSTRING(Standort.Bez, CHARINDEX(N' ', Standort.Bez, 1) + 1, CHARINDEX(N':', Standort.Bez, 1) - CHARINDEX(N' ', Standort.Bez, 1) - 1), IIF(Standort.Bez LIKE N'%ehem. Asten%', N'SMA', Standort.SuchCode)),
  LagerArt.Lagerart,
  ArtikelNr = UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)),
  Artikel.ArtikelNr AS Artikel,
  ArtGroe.Groesse,
  LgBewCod.Code AS LgBewCode,
  LgBewCod.IstEntnahme,
  LagerBew.Differenz,
  LagerBew.DiffWert,
  LagerBew.GleitPreis,
  LgBewCod.LgBewCodBez,
  Kunden.KdNr,
  LagerBew.Zeitpunkt,
  IsoCode = IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode),
  BKo.BestNr,
  BPo.Pos
FROM Salesianer.dbo.LagerBew
JOIN Salesianer.dbo.Bestand ON LagerBew.BestandID = Bestand.ID
JOIN Salesianer.dbo.LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Salesianer.dbo.ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Salesianer.dbo.ME ON Artikel.MeID = ME.ID
JOIN Salesianer.dbo.LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
JOIN Salesianer.dbo.Standort ON Lagerart.LagerID = Standort.ID
JOIN Salesianer.dbo.Kunden ON LagerBew.KundenID = Kunden.ID
JOIN Salesianer.dbo.LiefLsPo ON LagerBew.LiefLsPoID = LiefLsPo.ID
JOIN Salesianer.dbo.BPo ON LiefLsPo.BPoID = BPo.ID
JOIN Salesianer.dbo.BKo ON BPo.BKoID = BKo.ID
WHERE LagerBew.Zeitpunkt >= N'2019-01-01 00:00:00.000';