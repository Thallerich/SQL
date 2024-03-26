CREATE OR ALTER VIEW [sapbw].[V_BW_LIEFABPO] AS
SELECT N'ADV' AS [System],
	BKo.BestNr,
	BPo.Pos,
	SUM(LiefAbPo.Menge) AS LiefAbPoMenge,
	LiefAbPo.Termin AS LiefAbPoTermin,
	IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode) ASEinheit
FROM Salesianer.dbo.BPo
JOIN Salesianer.dbo.BKo ON BPo.BKoID = BKo.ID
JOIN Salesianer.dbo.ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Salesianer.dbo.ME ON Artikel.MeID = ME.ID
JOIN Salesianer.dbo.LiefAbPo ON LiefAbPo.BPoID = BPo.ID
WHERE BKo.Datum >= N'2019-01-01'
  AND (BKo.Update_ > DATEADD(day, -10, CAST(CAST(GETDATE() AS date) AS datetime2)) OR BPo.Update_ > DATEADD(day, -10, CAST(CAST(GETDATE() AS date) AS datetime2)) OR LiefAbPo.Update_ > DATEADD(day, -10, CAST(CAST(GETDATE() AS date) AS datetime2)))
GROUP BY BKo.BestNr, BPo.Pos, LiefAbPo.Termin, IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode);