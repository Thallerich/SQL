CREATE OR ALTER VIEW [sapbw].[V_BW_BESTELLUNGEN] AS
SELECT 'ADV' AS [System],
  BKo.BestNr,
	BKo.[Status],
	BKo.SentToSAP,
	Lief.LiefNr AS Lieferant,
	BKo.Datum,
	LagerStandort = IIF(Standort.SuchCode = N'SALESIANER MIET', SUBSTRING(Standort.Bez, CHARINDEX(N' ', Standort.Bez, 1) + 1, CHARINDEX(N':', Standort.Bez, 1) - CHARINDEX(N' ', Standort.Bez, 1) - 1), IIF(Standort.Bez = N'%ehem. Asten%', 'SMA',Standort.SuchCode)),
	CAST(BKo.FreigabeZeitpkt AS date) AS Freigabe,
	BPo.Pos,
	BPo.Einzelpreis,
	SUM(BPo.BestMenge) AS BestMenge,
	SUM(BPo.Menge) AS Menge,
	SUM(BPo.LiefMenge) AS LiefMenge,
	IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode) AS Einheit,
	UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS ArtikelNr,
	BPo.LiefDat,
	BPo.SollTermin,
	WAE.Symbol,
	WAE.IsoCode AS WAECODE,
	SUM(BPo.Einzelpreis * BPo.Menge) AS Preis,
	IIF(BKoArt.Kontrakt = 1, N'X', NULL) AS istkontrakt,
	KontraktBKo.BestNr AS Kontraktnr,
	KontraktBKo.Datum AS Kontraktdatum
FROM Salesianer.dbo.BPo
JOIN Salesianer.dbo.BKo ON BPo.BKoID = BKo.ID
JOIN Salesianer.dbo.Lief ON BKo.LiefID = Lief.ID
JOIN Salesianer.dbo.Standort ON BKo.LagerID = Standort.ID
JOIN Salesianer.dbo.ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Salesianer.dbo.ME ON Artikel.MeID = ME.ID
JOIN Salesianer.dbo.WAE ON Lief.WaeID = WAE.ID
JOIN Salesianer.dbo.BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN Salesianer.dbo.BPo AS KontraktBPo ON BPo.KontraktBpoID = KontraktBPo.ID
JOIN Salesianer.dbo.BKo AS KontraktBKo ON KontraktBPo.BKoID = KontraktBKo.ID
WHERE BKo.Datum >= N'2019-01-01' 
GROUP BY BKo.BestNr,
  BKo.[Status],
  BKo.SentToSAP,
  Lief.LiefNr,
  BKo.Datum,
  IIF(Standort.SuchCode = N'SALESIANER MIET', SUBSTRING(Standort.Bez, CHARINDEX(N' ', Standort.Bez, 1) + 1, CHARINDEX(N':', Standort.Bez, 1) - CHARINDEX(N' ', Standort.Bez, 1) - 1), IIF(Standort.Bez = N'%ehem. Asten%', 'SMA',Standort.SuchCode)),
  CAST(BKo.FreigabeZeitpkt AS date),
  BPo.Pos,
  BPo.Einzelpreis,
  IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode),
	UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)),
  BPo.LiefDat,
  BPo.SollTermin,
  WAE.Symbol,
  WAE.IsoCode,
  IIF(BKoArt.Kontrakt = 1, N'X', NULL),
  KontraktBKo.BestNr,
  KontraktBKo.Datum;