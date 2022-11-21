USE Salesianer_Archive;
GO

CREATE OR ALTER VIEW [sapbw].[V_BW_Kontrakt] AS
  SELECT KontraktKo.BestNr AS KontraktNr, KontraktPo.Pos AS Kontraktposition, UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS ArtikelNr, BKo.BestNr AS BestellNr, BPo.Pos AS Bestellposition
  FROM Salesianer.dbo.BPo AS KontraktPo
  JOIN Salesianer.dbo.BKo AS KontraktKo ON KontraktPo.BKoID = KontraktKo.ID
  JOIN Salesianer.dbo.BKoArt ON KontraktKo.BKoArtID = BKoArt.ID
  JOIN Salesianer.dbo.ArtGroe ON KontraktPo.ArtGroeID = ArtGroe.ID
  JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Salesianer.dbo.BPo ON BPo.KontraktBPoID = KontraktPo.ID
  JOIN Salesianer.dbo.BKo ON BPo.BKoID = BKo.ID
  WHERE BKoArt.Kontrakt = 1
    AND BPo.Menge != 0;

GO